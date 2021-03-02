# nostalgic-swartz - VMware NSX Advanced Load Balancer by Avi Networks on top of GCP infrastructure using Terraform + Ansible.

## Overview
Framework for deploying infrastructure on GCP leverages Terraform, which includes the creation of VPC networking components as well as VM instances for the Avi controller and a Jumpbox for testing/management. Ansible is used to configure Avi, including the basic system settings and creating a GCP cloud on a two-arm config mode. For more details please refer to the following articles:

https://avinetworks.com/docs/20.1/gcp-full-access-deployment-guide/
https://avinetworks.com/docs/20.1/configuring-gcp-cloud-network/


![Topology](nostalgic-swartz.png)

## Requirements
* Terraform 0.12.10 or later
* Ansible 2.6 or later
* Access keys to GCP
* Avi Controller Image (20.1.X) created on GCP   https://avinetworks.com/docs/20.1/gcp-full-access-deployment-guide/#upload

## Getting Started

**NOTE**: all the deployment work is suggested to be performed within avitools container: [https://github.com/avinetworks/avitools](https://github.com/avinetworks/avitools)

 1. Clone the repository [https://github.com/jaristizabalc/nostalgic-swartz](https://github.com/jaristizabalc/nostalgic-swartz)

```
root@avitools:~# git clone https://github.com/jaristizabalc/nostalgic-swartz
Cloning into ‘nostalgic-swartz'...
```

 2. Initialize a Terraform working directory
 ```
root@avitools:~/nostalgic-swartz# terraform init
Initializing the
backend... Initializing provider plugins... Checking for available
provider plugins...

* provider.local: version = "~> 1.4"
* provider.random: version = "~> 2.2"
* provider.template: version = "~> 2.1"
* provider.tls: version = "~> 2.1"
* provider.vsphere: version = "~> 1.17"

Terraform has been successfully initialized!
```
3. Copy the minimum required variables template
```
root@avitools:~/nostalgic-swartz# cp sample_terraform_tfvars terraform.tfvars
```
4. Fill out the required variables - terraform.tfvars

```
avi_admin_password = "AviNetworks123!"
avi_default_password = "58NFaGDJm(PJH0G"
avi_api_version = "20.1.3"
pod_count = 1
id = "avigcp"
owner = 

project_id = 
gcp_region = 
gcp_zone = 
controller_image = 

gcp_key_file = 
vip_network_cidr = "192.168.1.0/24"
domain_name = 
se_machine_type = "n1-standard-4"

```
gcp_key_file is a json format file containing the authentication keys, refer to this article for more information:
https://cloud.google.com/iam/docs/creating-managing-service-account-keys

5. Update vars_infra.tf with appropriate VM template names for jumpbox and controller objects
```
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
```
6. Update vars_pod.tf with appropriate id and owner values
```
variable "id" {
  description = "A prefix for the naming of the objects / instances"
  default     = "avigcp"
}

variable "owner" {
  description = "Sets the GCP Owner tag appropriately"
  default     = "avi-tf"
}
```
7. Prepare the terraform plan
```
root@avitools:~/nostalgic-swartz# terraform plan
Plan: 22 to add, 0 to change, 0 to destroy.
------------------------------------------------------------------------
Note: You didn't specify an "-out" parameter to save this plan, so
Terraform can't guarantee that exactly these actions will be performed
if "terraform apply" is subsequently run
```
7. Apply the terraform plan
```
aviadmin@avitools:~/nostalgic-swartz# terraform apply

Plan: 22 to add, 0 to change, 0 to destroy.
Do you want to perform these actions?   Terraform will perform the
actions described above.   Only 'yes' will be accepted to approve.

Enter a value: yes

Apply complete! Resources: 22 added, 0 changed, 0 destroyed.

```
