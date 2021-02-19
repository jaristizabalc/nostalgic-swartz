output "subnets" {
  value       = [for network in module.vpc-mgmt.subnets : network.name]
  description = "A map with keys of form subnet_region/subnet_name and values being the outputs of the google_compute_subnetwork resources used to create corresponding subnets."
}

output "Jumpbox_PublicIP" {
  value = google_compute_instance.jumpbox.network_interface.0.access_config.0.nat_ip
}

output "Controller_PublicIP" {
  value = google_compute_instance.avi-controller.*.network_interface.0.access_config.0.nat_ip
}

output "Controller_PrivateIP" {
  value = google_compute_instance.avi-controller.*.network_interface.0
}
