# Web Front End static IP
resource "google_compute_global_address" "api-static-ip" {
  name         = "api-static-ip"
  address_type = "EXTERNAL"
  project      = var.vpc_info.project_id
  #network      = var.vpc_info.network_name
}

# UI Web static IP
resource "google_compute_global_address" "ui-static-ip" {
  name         = "ui-static-ip"
  address_type = "EXTERNAL"
  project      = var.vpc_info.project_id
  #network      = var.vpc_info.network_name
}

resource "google_dns_managed_zone" "provenid" {
  name     = "provenid-zone"
  dns_name = var.dns.zone
}

resource "google_dns_record_set" "api" {
  name = var.dns.api_domain
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.provenid.name

  rrdatas = [google_compute_global_address.api-static-ip.address]
}

resource "google_dns_record_set" "ui" {
  name = var.dns.ui_domain
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.provenid.name

  rrdatas = [google_compute_global_address.ui-static-ip.address]
}
