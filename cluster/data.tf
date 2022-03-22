# Query the client configuration for our current service account, which shoudl
# have permission to talk to the GKE cluster since it created it.
data "google_client_config" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket = var.vpc_terraform_bucket
    prefix = var.vpc_terraform_prefix
  }
}

#data "terraform_remote_state" "shared" {
#  backend = "gcs"
#  config = {
#    bucket = "provenid-shared-terraform"
#    prefix = "shared/provenid"
#  }
#}


# Retrieves the GKE subnet
data "google_compute_subnetwork" "gke_subnet" {
  name    = var.subnet
  region  = var.region
  project = var.shared_vpc_project
}

# Retrieves the Compute subnet
#data "google_compute_subnetwork" "gce_subnet" {
#  name    = "provenid-net1"                  # TODO: variable
#  region  = "${var.region}"
#  project = "${var.shared_vpc_project}"
#}

data "google_compute_network" "shared_vpc" {
  name    = var.network
  project = var.shared_vpc_project
}

data "google_container_cluster" "provenid" {
  name     = var.cluster_name
  location = data.terraform_remote_state.vpc.outputs.shared.default_region
}