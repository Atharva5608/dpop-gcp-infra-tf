provider "google" {
  project = var.vpc_info.project_id
}

provider "google-beta" {
  project = var.vpc_info.project_id
  region  = var.region
}

