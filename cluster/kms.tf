resource "google_kms_key_ring" "default" {
  name     = "default"
  location = data.terraform_remote_state.vpc.outputs.shared.default_region
  project  = var.project_id
}

resource "google_kms_key_ring" "provenid" {
  name     = "provenid"
  location = data.terraform_remote_state.vpc.outputs.shared.default_region
  project  = var.project_id
}

resource "google_kms_key_ring_iam_binding" "provenid-cloudkms-admin" {
  key_ring_id = google_kms_key_ring.provenid.id
  role        = "roles/cloudkms.admin"

  members = [
    data.terraform_remote_state.vpc.outputs.shared.se_iam_group,
    "serviceAccount:${google_service_account.provenid.email}",
  ]
}

resource "google_kms_key_ring_iam_binding" "provenid-cloudkms-signer" {
  key_ring_id = google_kms_key_ring.provenid.id
  role        = "roles/cloudkms.signerVerifier"

  members = [
    data.terraform_remote_state.vpc.outputs.shared.se_iam_group,
    "serviceAccount:${google_service_account.provenid.email}",
  ]
}

