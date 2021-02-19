# This file contains various variables that affect the deployment itself
#

# The following variables should be defined via a seperate mechanism to avoid distribution
# For example the file terraform.tfvars

variable "avi_default_password" {
}
variable "avi_admin_password" {
}

variable "avi_backup_admin_username" {
  default = "avi_bkp"
}

variable "avi_backup_admin_password" {
  default = "AviNetworks123!"
}

variable "avi_api_version" {
}

variable "pod_count" {
  description = "The pod size. Each pod gets a controller"
  default     = 1
}

variable "lab_timezone" {
  description = "Lab Timezone: PST, EST, GMT or SGT"
  default = "est"
}

variable "server_count" {
  description = "K8S Workers count per pod"
  default     = 1
}

variable "master_count" {
  description = "K8S Masters count per pod"
  default     = 1
}

variable "id" {
  description = "A prefix for the naming of the objects / instances"
  default     = "avigcp"
}

variable "owner" {
  description = "Sets the GCP Owner tag appropriately"
  default     = "avi-tf"
}