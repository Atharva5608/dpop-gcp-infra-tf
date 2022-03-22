module "provenid-net-vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id              = var.vpc_info.project_id
  network_name            = var.vpc_info.network_name
  routing_mode            = "GLOBAL"
  shared_vpc_host         = "false"
  auto_create_subnetworks = "false"
  description             = "VPC for ${var.vpc_info.project_id}"

  subnets = [for s in var.vpc_subnets : {
    subnet_name           = s.name
    subnet_ip             = contains(keys(s), "unmanaged") ? cidrsubnet(s.range, 0, 0) : cidrsubnet(s.range, 2, 0) # 10.x.0.0/18
    subnet_region         = var.region
    subnet_private_access = "true"
  }]

  # This weird statement is to allow for subnets that don't have secondary ranges. This module requires you to return a list of secondary ranges
  # for each subnet you have, empty if no secondary ranges wanted.
  secondary_ranges = { for s in var.vpc_subnets : s.name => contains(keys(s), "unmanaged") ? [] : [
    {
      range_name    = contains(keys(s), "service_range_name") ? s.service_range_name : "services",
      ip_cidr_range = cidrsubnet(s.range, 2, 1) # 10.x.64.0/18
    },
    {
      range_name    = contains(keys(s), "pod_range_name") ? s.pod_range_name : "pods",
      ip_cidr_range = cidrsubnet(s.range, 1, 1) # 10.x.128.0/17
    },
  ] }

  routes = [
    {
      name              = var.route_to_internet
      description       = "Default route to the Internet."
      destination_range = "0.0.0.0/0"
      next_hop_internet = "true"
    },
  ]
}

resource "google_compute_global_address" "private_ip_block" {
  name          = "private-ip-block"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 20
  network       = module.provenid-net-vpc.network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = module.provenid-net-vpc.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
}
