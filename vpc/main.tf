# Allows management of a single API service for an existing Google Cloud Platform project.
# https://www.terraform.io/docs/providers/google/d/google_project_services.html
resource "google_project_service" "google_project_services" {
  project = var.vpc_info.project_id
  count   = length(local.services)
  service = element(local.services, count.index)

  disable_on_destroy = "false"
}
