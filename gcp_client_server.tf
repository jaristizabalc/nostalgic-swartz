# Terraform definition for the client server
#Need to access it from the JumpBox, VM only for testing VIP access

resource "google_compute_instance" "client" {
  name         = "client-lab"
  machine_type = var.server["machine_type"]
  zone         = var.gcp_zone
  tags          = ["ssh"]

  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.server["image"]
      size  = var.server["disk"]
      type   = var.server["disk_type"]
    }
  }
  labels = {
    name                            = "client-server-lab"
    owner                           = var.owner
    lab_group                       = "client"
    lab_name                        = "client-server-lab"
    ansible_connection              = "local"
    lab_timezone                    = var.lab_timezone
    lab_noshut                      = "client-server"
  }  
  network_interface {
    subnetwork    = var.frontend_network["client_subnet"]
  }
  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.generated.public_key_openssh}"

  }
}
