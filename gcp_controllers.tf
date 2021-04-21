# Terraform definition for the controllers

# It is a prereq to have created the disk image, follow https://avinetworks.com/docs/18.2/gcp-full-access-deployment-guide/#image
data "google_compute_image" "controller-diskimage" {
  name  = "avi-controller-2013"
}
locals {
  jumpbox_private_ip = google_compute_instance.jumpbox.network_interface.0.network_ip
}
data "template_file" "controller_config_data" {
  template  = file("${path.module}/provisioning/config_vars.tpl")

  vars = {
    keyfile_data = var.gcp_key_file
    avi_default_pass = var.avi_default_password
    gcp_region = var.gcp_region
    se_project_id = var.project_id
    frontend_data_vpc_subnet_name = var.frontend_network["se_subnet"]
    management_vpc_subnet_name = var.mgmt_network["se_subnet"]
    backend_data_vpc_subnet_name = var.backend_network["se_subnet"]
    frontend_data_vpc_network_name = var.frontend_network["vpc_name"]
    management_vpc_network_name = var.mgmt_network["vpc_name"]
    backend_data_vpc_network_name = var.backend_network["vpc_name"]
    worker_cidr = var.gke_network["worker_cidr"]
    backend_se_gw = cidrhost(cidrsubnet(var.backend_network["cidr"],8,1),1)
    vip_network_cidr = var.vip_network_cidr
    domain_name = var.domain_name
    se_machine_type = var.se_machine_type
    password = var.avi_admin_password
    api_version = var.avi_api_version
    gke_pod_cidr = var.gke_network["ip_range_pods_cidr"]
  }
}
resource "local_file" "controller_vars" {
    content     = data.template_file.controller_config_data.rendered
    filename = "${path.module}/provisioning/config_vars.yaml"
}
resource "google_compute_instance" "avi-controller" {
  count = var.pod_count
  name         = "${var.id}-pod${count.index + 1}-controller-1"
  machine_type = var.controller["machine_type"]
  zone         = var.gcp_zone
  tags          = ["avi"]

  boot_disk {
    auto_delete = true
    initialize_params {
      image = data.google_compute_image.controller-diskimage.self_link
      size  = var.controller["disk"]
      type  = var.controller["disk_type"]
    }
  }
  labels = {
    name               = "${var.id}-pod${count.index + 1}-controller"
    owner              = var.owner
    lab_group          = "controllers"
    lab_name           = "controller-pod${count.index + 1}-lab"
    ansible_connection = "local"
    lab_timezone       = var.lab_timezone
  }
  network_interface {
    subnetwork    = var.mgmt_network["mgmt_subnet"]
    access_config {
      // Include this section to give the VM an external ip address
    }
  }
  depends_on = [google_compute_instance.jumpbox]
  provisioner "local-exec"{
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -e'controller_ip=${self.network_interface.0.access_config.0.nat_ip}' provisioning/config_controller.yaml"
  }

}
