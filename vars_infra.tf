variable "project_id" {
  description = "The project ID to host the cluster in"
}
variable "gcp_key_file" {
  description = "Key in JSON format for GCP access, controller config needs it"
}
variable "gcp_region" {
}
variable "gcp_zone" {
}
#Network definitions
variable "mgmt_network" {
  type = map
  description = "Management Network information"
  default     = { 
    mgmt_subnet = "mgmt-subnet"
    se_subnet =  "se-subnet-mgmt"
    vpc_name = "jda-tf-mgmt-vpc"
    cidr = "10.10.0.0/16"
  }
}
variable "frontend_network" {
  type = map
  description = "Frontend Network information"
  default     = { 
    client_subnet = "client-subnet"
    se_subnet =  "se-subnet-frontend"
    vpc_name = "jda-tf-frontend-vpc"
    cidr = "10.20.0.0/16"
  }
}
variable "backend_network" {
  type = map
  description = "Backend Network information"
  default     = { 
    app_subnet = "app-subnet"
    se_subnet =  "se-subnet-backend"
    vpc_name = "jda-tf-backend-vpc"
    cidr = "10.30.0.0/16"
  }
}
variable "gke_network" {
  type = map
  description = "GKE Network information"
  default     = { 
    worker_subnet = "gke-worker-subnet"
    worker_cidr =  "10.100.0.0/16"
    ip_range_pods = "gke-pod-range"
    ip_range_pods_cidr = "10.110.0.0/16"
    ip_range_services = "gke-services-range"
    ip_range_services_cidr = "10.120.0.0/16"
    vpc_name = "jda-tf-gke-vpc"
  }
}
#Avi Specific
variable "vip_network_cidr" {
  description = "VIP Network for VSs"
}
variable "domain_name" {
  description = "FQDN for Cloud DNS profile"
}
variable "se_machine_type" {
  description = "Avi SE machine type"
}
#VM instances definitions
variable "jumpbox" {
  type = map
  description = "Jumpbox config"
  default     = { 
    machine_type = "n1-standard-2"
    disk = "60"
    image = "ubuntu-os-cloud/ubuntu-1604-lts"
    disk_type = "pd-standard"
  }
}
variable "controller" {
  type = map
  description = "GCP instance type for Avi controllers"
  default     = { 
    machine_type = "n1-standard-4"
    disk = 128
    disk_type = "pd-ssd" 
  }
}
variable "server" {
  type = map
  description = "GCP instance type for servers"
  default     = { 
    machine_type = "n1-standard-2"
    disk = 10
    image = "ubuntu-os-cloud/ubuntu-1604-lts"
    disk_type = "pd-standard"
  }
}
variable "gke_node_info" {
  type = map
  description = "Collection of GKE nodes comfiguration variables"
  default     = {
    machine_type = "e2-medium"
    disk = 30
    min_count = 1
    max_count = 2
    locations = "us-west1-a,us-west1-b,us-west1-c"
  }
}