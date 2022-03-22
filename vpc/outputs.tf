# Put all the things that you need access from outside of this module in here.
# You will need a block like the commented out one below in the other module you're trying to read
# these in from.
#
# The outputs from this module will have names like the following:
#
# data.terraform_remote_state.vpc.outputs.shared.org_id
#
# data "terraform_remote_state" "vpc" {
#   backend = "gcs"
#
#   config = {
#     bucket = "provenid-terraform"
#     prefix = "${terraform.workspace}/provenid-vpc"
#   }
# }

output "shared" {
  value = {
    org_id          = var.org_id
    billing_account = var.billing_account
    default_region  = var.region
    default_zone    = var.zone
    dev_iam_group   = var.dev_iam_group
    se_iam_group    = var.se_iam_group
    workspace       = "${terraform.workspace}"
    api_domain      = var.dns.api_domain
    ui_domain       = var.dns.ui_domain
  }
}

output "vpc_info" {
  value = {
    network_name         = var.vpc_info.network_name
    subnets_self_links   = module.provenid-net-vpc.subnets_self_links
    svpc_host_project_id = var.vpc_info.project_id
    vpc_subnets          = var.vpc_subnets
    network_self_link    = module.provenid-net-vpc.network_self_link
    api_ip               = google_compute_global_address.api-static-ip.address
    ui_ip                = google_compute_global_address.ui-static-ip.address
    nat_ips              = google_compute_address.nat-gateway-ips.*.address
  }
}
