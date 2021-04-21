module "vpc-mgmt" {
    source  = "terraform-google-modules/network/google"
    version = "~> 3.2.0"
    project_id   = var.project_id
    network_name = var.mgmt_network["vpc_name"]
    routing_mode = "REGIONAL"
    subnets = [
        {
            subnet_name           = var.mgmt_network["mgmt_subnet"]
            subnet_ip             = cidrsubnet(var.mgmt_network["cidr"],8,1)  #"10.10.1.0/24"
            subnet_region         = var.gcp_region
            description		        = "Controller and jumpbox subnet"
        },
        {
            subnet_name           = var.mgmt_network["se_subnet"]
            subnet_ip             = cidrsubnet(var.mgmt_network["cidr"],8,2)  #"10.10.2.0/24"
            subnet_region         = var.gcp_region
            description           = "SE mgmt subnet"
        }
    ]
}
#For practical reasons a VPC for frontend is created, this is in general a Shared VPC to allow multiple users
#to consume LB services
module "vpc-frontend" {
    source  = "terraform-google-modules/network/google"
    version = "~> 3.2.0"
    project_id   = var.project_id
    network_name = var.frontend_network["vpc_name"]
    routing_mode = "REGIONAL"
    subnets = [
        {
            subnet_name           = var.frontend_network["se_subnet"]
            subnet_ip             = cidrsubnet(var.frontend_network["cidr"],8,1)  #"10.20.1.0/24"
            subnet_region         = var.gcp_region 
            description           = "SE frontend subnet"
        },
        {
            subnet_name           = var.frontend_network["client_subnet"]
            subnet_ip             = cidrsubnet(var.frontend_network["cidr"],8,2)  #"10.20.2.0/24"
            subnet_region         = var.gcp_region
            description           = "Client subnet"
        }
    ]
}
module "vpc-backend" {
    source  = "terraform-google-modules/network/google"
    version = "~> 3.2.0"
    project_id   = var.project_id
    network_name = var.backend_network["vpc_name"]
    routing_mode = "REGIONAL"
    subnets = [
        {
            subnet_name           = var.backend_network["se_subnet"]
            subnet_ip             = cidrsubnet(var.backend_network["cidr"],8,1)  #"10.30.1.0/24"
            subnet_region         = var.gcp_region
            description           = "SE backend subnet"
        },
        {
            subnet_name           = var.backend_network["app_subnet"]
            subnet_ip             = cidrsubnet(var.backend_network["cidr"],8,2) #"10.30.2.0/24"
            subnet_region         = var.gcp_region
            description           = "Application subnet"
        }
    ]
}
module "vpc-gke" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 3.2.0"
  project_id   = var.project_id
  network_name = var.gke_network["vpc_name"]
  subnets = [
    {
      subnet_name   = var.gke_network["worker_subnet"] 
      subnet_ip     = var.gke_network["worker_cidr"]  #"10.100.0.0/16"
      subnet_region = var.gcp_region
    },
  ]
  secondary_ranges = {
    (var.gke_network["worker_subnet"]) = [
      {
        range_name    = var.gke_network["ip_range_pods"]
        ip_cidr_range = var.gke_network["ip_range_pods_cidr"] #"10.110.0.0/16"
      },
      {
        range_name    = var.gke_network["ip_range_services"]
        ip_cidr_range = var.gke_network["ip_range_services_cidr"] #"10.120.0.0/16"
      },
    ]
  }
}
#Configure Cloud NAT to allow GKE nodes to reach the Internet (required for pulling images from dockerhub and AKO installation)
module "cloud_router_gke" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4"
  project = var.project_id # Replace this with your project ID in quotes
  name    = var.gke_network["cloud_router_name"]
  network = var.gke_network["vpc_name"]
  region  = var.gcp_region

  nats = [{
    name = var.gke_network["nat_gw"]    //restrict NAT sources to primary IPs only???
  }]
}

#VPC Peerings
module "peering-backend-gke" {
  source = "terraform-google-modules/network/google//modules/network-peering"

  prefix        = "backend-gke-peering"
  local_network = module.vpc-backend.network_self_link
  peer_network  = module.vpc-gke.network_self_link
  #export_local_custom_routes = true
}
#Required for AKO, GKE -> MGMT
module "peering-mgmt-gke" {
  source = "terraform-google-modules/network/google//modules/network-peering"

  prefix        = "mgmt-gke-peering"
  local_network = module.vpc-mgmt.network_self_link
  peer_network  = module.vpc-gke.network_self_link
  #export_local_custom_routes = true
}
#Firewall rules Management Network
module "net-firewall-mgmt" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = var.project_id
  network                 = module.vpc-mgmt.network_name
  internal_ranges_enabled = true
  internal_ranges         = [var.mgmt_network["cidr"]]
  internal_allow = [
    {
      protocol = "icmp"
    },
    {
      protocol = "tcp",
    },
    {
      protocol = "udp"
      # all ports will be opened if `ports` key isn't specified
    },
  ]
  custom_rules = {
    ssh-jumpbox = {
      description          = "SSH for JumpBox"
      direction            = "INGRESS"
      action               = "allow"
      ranges               = ["0.0.0.0/0"]
      sources              = null
      targets              = ["ssh"]
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
      extra_attributes = {}
    },
    controller-https = {
      description          = "Controller UI access"
      direction            = "INGRESS"
      action               = "allow"
      ranges               = ["0.0.0.0/0"]
      sources              = null
      targets              = ["avi"]
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports    = ["443","80"]
        }
      ]
      extra_attributes = {}
    },
    ako-traffic = {
      description          = "Allow traffic from the AKO container to the controller"
      direction            = "INGRESS"
      action               = "allow"
      ranges               = [var.gke_network["ip_range_pods_cidr"]]
      sources              = null
      targets              = null
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports    = ["443","8443"]
        }
      ]
      extra_attributes = {}
    } 
  
  } 
}
#TODO
#Add Firewall rules for the rest of the VPCs
#Narrow down access for AKO and exposed services
#VPC Peering FW rules
locals {  
  custom_rules = {
    backend-peering = {
      description          = "Backend to K8s services on GKE"
      direction            = "INGRESS"
      action               = "allow"
      ranges               = [var.backend_network["cidr"],var.mgmt_network["cidr"]]   #rule for mgmt not required, only for testing
      sources              = null
      targets              = null
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports    = ["80","443","30000-32767"]
        },
        {
          protocol = "udp"
          ports    = ["30000-32767"]
        }
      ]
      extra_attributes = {}
    } 
  }
}
module "net-firewall-gke" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = var.project_id
  network                 = module.vpc-gke.network_name
  internal_ranges_enabled = true
  internal_ranges         = [var.gke_network["worker_cidr"],var.gke_network["ip_range_pods_cidr"],var.gke_network["ip_range_services_cidr"]]
  internal_allow = [
    {
      protocol = "icmp"
    },
    {
      protocol = "tcp",
    },
    {
      protocol = "udp"
      # all ports will be opened if `ports` key isn't specified
    },
  ]
  custom_rules = local.custom_rules
}
module "net-firewall-frontend" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = var.project_id
  network                 = module.vpc-frontend.network_name
  internal_ranges_enabled = true
  internal_ranges         = [var.frontend_network["cidr"]]
  internal_allow = [
    {
      protocol = "icmp"
    },
    {
      protocol = "tcp",
    },
    {
      protocol = "udp"
      # all ports will be opened if `ports` key isn't specified
    },
  ]
}