# Terraform definition for the lab jumpbox
#

data "template_file" "jumpbox_userdata" {
  template = file("${path.module}/userdata/jumpbox.userdata")

  vars = {
    hostname     = "jumpbox.pod.lab"
    server_count = var.pod_count
    vpc_id       = module.vpc-mgmt.network_self_link
    region       = var.gcp_region
    az           = var.gcp_zone
    mgmt_net     = var.mgmt_network["mgmt_subnet"]
    pkey         = tls_private_key.generated.private_key_pem
    pubkey       = tls_private_key.generated.public_key_openssh
  }
}


resource "google_compute_instance" "jumpbox" {
  name         = "jumpbox"
  machine_type = var.jumpbox["machine_type"]
  zone         = var.gcp_zone
  tags          = ["ssh"]

  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.jumpbox["image"]
      size  = var.jumpbox["disk"]
      type   = var.jumpbox["disk_type"]
    }
  }
  labels = {
    name                            = "jumpbox-pod-lab"
    owner                           = var.owner
    lab_group                       = "jumpbox"
    lab_name                        = "jumpbox-pod-lab"
    ansible_connection              = "local"
    lab_avi_mgmt_net                = "${var.id}_mgmt-subnet"
    lab_avi_app_net                 = "${var.id}_app-subnet"
    lab_timezone                    = var.lab_timezone
    lab_noshut                      = "jumpbox"
  }  
  network_interface {
    subnetwork    = var.mgmt_network["mgmt_subnet"]
    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  #second and third interfaces to access other VPCs frontend/backend
  network_interface {
    subnetwork    = var.frontend_network["client_subnet"]
  }
  metadata = {
    user-data = data.template_file.jumpbox_userdata.rendered
    ssh-keys = "ubuntu:${tls_private_key.generated.public_key_openssh}"

  }
  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    agent       = false
    user        = "ubuntu"
    private_key = tls_private_key.generated.private_key_pem
  }
  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloud-init.done ]; do sleep 1; done"
    ]
  }
}
