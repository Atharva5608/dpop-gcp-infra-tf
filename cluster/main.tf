# The resource random_id generates random numbers that are intended to be used as unique identifiers for other resources.
# https://www.terraform.io/docs/providers/random/r/id.html
resource "random_id" "id" {
  byte_length = 2
}

# Allows management of a single API service for an existing Google Cloud Platform project.
# https://www.terraform.io/docs/providers/google/d/google_project_services.html
resource "google_project_service" "google_project_services" {
  project = var.project_id
  count   = length(local.services)
  service = element(local.services, count.index)

  disable_on_destroy = "false"
}

# Non-authoritative. Updates the IAM policy to grant a role to a new member.
# https://www.terraform.io/docs/providers/google/r/google_project_iam.html
resource "google_project_iam_member" "role-binding-osadminlogin" {
  project = var.project_id
  role    = "roles/compute.osAdminLogin"
  member  = "serviceAccount:${var.node_service_account}"
}

resource "google_project_iam_member" "role-binding-svcacctactor" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${var.node_service_account}"
}

resource "google_project_iam_member" "role-binding-db" {
  project = var.project_id
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${var.node_service_account}"
}

resource "google_project_iam_member" "role-logs" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${var.node_service_account}"
}

resource "google_project_iam_member" "role-metrics" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${var.node_service_account}"
}