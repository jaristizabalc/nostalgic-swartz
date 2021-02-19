module "vpc-mgmt" {
    source  = "terraform-google-modules/network/google"
    version = "~> 3.0"

    project_id   = var.project_id
    network_name = var.mgmt_vpc
    routing_mode = "REGIONAL"

    subnets = [
        {
            subnet_name           = var.mgmt_subnet
            subnet_ip             = "10.10.1.0/24"
            subnet_region         = var.gcp_region
            description		  = "Controller and jumpbox subnet"
        },
        {
            subnet_name           = var.se_mgmt_subnet
            subnet_ip             = "10.10.2.0/24"
            subnet_region         = var.gcp_region
            description           = "SE mgmt subnet"
        }
    ]

}
#For practical reasons a VPC for frontend is created, this is in general a Shared VPC to allow multiple users
#to consume LB services
module "vpc-frontend" {
    source  = "terraform-google-modules/network/google"
    version = "~> 3.0"

    project_id   = var.project_id
    network_name = var.frontend_vpc
    routing_mode = "REGIONAL"

    subnets = [
        {
            subnet_name           = var.se_subnet_frontend
            subnet_ip             = "10.20.1.0/24"
            subnet_region         = var.gcp_region
            description           = "SE frontend subnet"
        },
        {
            subnet_name           = var.client_subnet
            subnet_ip             = "10.20.2.0/24"
            subnet_region         = var.gcp_region
            description           = "Client subnet"
        }
    ]

}

module "vpc-backend" {
    source  = "terraform-google-modules/network/google"
    version = "~> 3.0"

    project_id   = var.project_id
    network_name = var.backend_vpc
    routing_mode = "REGIONAL"

    subnets = [
        {
            subnet_name           = var.se_backend_subnet
            subnet_ip             = "10.30.1.0/24"
            subnet_region         = var.gcp_region
            description           = "SE backend subnet"
        },
        {
            subnet_name           = var.app_subnet
            subnet_ip             = "10.30.2.0/24"
            subnet_region         = var.gcp_region
            description           = "Application subnet"
        }
    ]

}

module "net-firewall-mgmt" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = var.project_id
  network                 = module.vpc-mgmt.network_name
  internal_ranges_enabled = true
  internal_ranges         = ["10.10.0.0/16"]
  #internal_target_tags    = ["internal"]
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
          ports    = ["443"]
        }
      ]
      extra_attributes = {}
    }
  } 
}
