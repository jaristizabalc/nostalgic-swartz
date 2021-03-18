module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [module.gke]
  project_id   = var.project_id
  location     = module.gke.location
  cluster_name = module.gke.name
}
resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "kubeconfig-${var.id}"
}
module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id             = var.project_id
  name                   = "${var.owner}-${var.id}-gke-cluster"
  regional               = true
  region                 = var.gcp_region
  network                = module.vpc-gke.network_name
  subnetwork             = module.vpc-gke.subnets_names[0]
  ip_range_pods          = var.gke_network["ip_range_pods"]
  ip_range_services      = var.gke_network["ip_range_services"]
  node_pools = [
    {
      name                      = "node-pool-${var.id}"
      machine_type              = var.gke_node_info["machine_type"]
      node_locations            = var.gke_node_info["locations"]
      min_count                 = var.gke_node_info["min_count"]
      max_count                 = var.gke_node_info["max_count"]
      disk_size_gb              = var.gke_node_info["disk"]
    },
  ]
}