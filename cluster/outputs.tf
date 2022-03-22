
output "shared" {
  value = {
    org_id            = var.org_id
    default_region    = var.region
    cluster_name      = var.cluster_name
    subnetwork        = var.subnet
    ip_range_pods     = data.google_compute_subnetwork.gke_subnet.secondary_ip_range[0].ip_cidr_range
    ip_range_services = data.google_compute_subnetwork.gke_subnet.secondary_ip_range[1].ip_cidr_range
    api_domain        = data.terraform_remote_state.vpc.outputs.shared.api_domain
    ui_domain         = data.terraform_remote_state.vpc.outputs.shared.ui_domain
  }
}

output "sql" {
  value = {
    master_name        = google_sql_database_instance.master.name
    master_connection  = google_sql_database_instance.master.connection_name
    ip_address         = google_sql_database_instance.master.ip_address
    public_ip_address  = google_sql_database_instance.master.public_ip_address
    private_ip_address = google_sql_database_instance.master.private_ip_address
  }
}
