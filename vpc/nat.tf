/*
locals {
  auto_generated_ips = [
    "nat-auto-ip-5596639-0-1588665540192314",
    "nat-auto-ip-5596639-0-1598623146044217",
    "nat-auto-ip-5596639-5-1567691928867275",
    "nat-auto-ip-5596639-5-1577036239004325",
  ]
}

resource "google_compute_address" "nat-gateway-auto-assigned" {
  count        = length(local.auto_generated_ips)
  name         = local.auto_generated_ips[count.index]
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  region       = var.region
  project      = var.vpc_info.project_id
}
*/

resource "google_compute_address" "nat-gateway-ips" {
  count        = 2
  name         = "nat-gateway-ip-${count.index}"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  region       = var.region
  project      = var.vpc_info.project_id
}

resource "google_compute_router" "provenid-net-router-1" {
  name    = "provenid-net-router-1"
  region  = var.region
  project = var.vpc_info.project_id
  network = module.provenid-net-vpc.network_name
  bgp {
    asn = 64514 # private asn
  }
}

resource "google_compute_router_nat" "provenid-net-nat-1" {
  name                               = "provenid-net-nat-1"
  router                             = google_compute_router.provenid-net-router-1.name
  region                             = var.region
  project                            = var.vpc_info.project_id
  
  #nat_ip_allocate_option             = "AUTO_ONLY"

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat-gateway-ips.*.self_link

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "provenid-ingress" {
  name        = "provenid-ingress"
  description = "Ingress to service"
  project     = var.vpc_info.project_id
  network     = var.vpc_info.network_name
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["18444", "18443", "443"]
  }

  depends_on = [
    module.provenid-net-vpc
  ]
}

