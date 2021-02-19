# Specifies the details for the GCP Terraform provider
# https://www.terraform.io/docs/providers/aws/

provider "google" {
  credentials = "${file(var.gcp_key_file)}"
  project     = var.project_id
  region      = var.gcp_region
}

