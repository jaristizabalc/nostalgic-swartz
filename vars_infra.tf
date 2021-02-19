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
variable "mgmt_subnet" {
  description = "MGMT subnet name"
  default = "mgmt-subnet"
}
variable "client_subnet" {
  description = "Client subnet name"
  default = "client-subnet"
}
variable "app_subnet" {
  description = "Application/backend subnet name"
  default = "app-subnet"
}
#Organize
variable "se_subnet_frontend" {
  description = "SE subnet name frontend"
  default = "se-subnet-frontend"

}
variable "se_mgmt_subnet" {
  description = "SE subnet name mgmt"
  default = "se-subnet-mgmt"

}
variable "se_backend_subnet" {
  description = "SE subnet name backend"
  default = "se-subnet-backend"

}
variable "backend_vpc" {
  description = "VPC backend name"
  #default = "${var.id}-backend-vpc"
  default = "jda-tf-backend-vpc"

}
variable "frontend_vpc" {
  description = "VPC frontend name"
  default = "jda-tf-frontend-vpc"

}
variable "mgmt_vpc" {
  description = "VPC mgmt name"
  default = "jda-tf-mgmt-vpc"

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
    disk = 20
    image = "ubuntu-os-cloud/ubuntu-1604-lts"
  }
}
