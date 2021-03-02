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
