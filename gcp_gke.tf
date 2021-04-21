module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [module.gke_cluster]
  project_id   = var.project_id
  location     = module.gke_cluster.location
  cluster_name = module.gke_cluster.name
}
resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "kubeconfig-${var.id}"
}
module "gke_cluster" {
  source                 = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id             = var.project_id
  name                   = "${var.owner}-${var.id}-gke-cluster"
  regional               = true
  region                 = var.gcp_region
  network                = module.vpc-gke.network_name
  subnetwork             = module.vpc-gke.subnets_names[0]
  ip_range_pods          = var.gke_network["ip_range_pods"]
  ip_range_services      = var.gke_network["ip_range_services"]
  enable_private_nodes   = true
  http_load_balancing    = false          #for AKO to replace cloud native load balancer
  network_policy         = true

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
  #node_pools_oauth_scopes = {
  #  all = []
  #
  #  default-node-pool = [
  #    "https://www.googleapis.com/auth/cloud-platform",
  #  ]
  #}
}
#Create K8s resources upon cluster creation
resource "null_resource" "k8s-object-crration" {
  depends_on = [module.gke_cluster] 
  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      kubectl --kubeconfig ${local_file.kubeconfig.filename} create -f k8s/apps/avinetworks.yaml
      kubectl --kubeconfig ${local_file.kubeconfig.filename} create -f k8s/apps/dvwa.yaml
      kubectl --kubeconfig ${local_file.kubeconfig.filename} create -f k8s/apps/hackazon.yaml
      kubectl --kubeconfig ${local_file.kubeconfig.filename} create -f k8s/apps/juice.yaml
      kubectl --kubeconfig ${local_file.kubeconfig.filename} create -f k8s/apps/kuard.yaml
    EOT
    }
}