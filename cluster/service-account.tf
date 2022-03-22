#
# provenid
#

resource "google_service_account" "provenid" {
  account_id   = "provenid"
  display_name = "provenid"
  project      = var.project_id
}

resource "google_service_account_iam_binding" "provenid-workload-identity-iam" {
  service_account_id = google_service_account.provenid.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[provenid/provenid-api]",
  ]
}

resource "google_project_iam_member" "provenid-cloudsql-role" {
  project = var.project_id
  role    = "roles/cloudsql.editor"
  member  = "serviceAccount:${google_service_account.provenid.email}"
}

resource "google_project_iam_member" "provenid-logwriter-role" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.provenid.email}"
}

resource "google_project_iam_member" "provenid-metricwriter-role" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.provenid.email}"
}
