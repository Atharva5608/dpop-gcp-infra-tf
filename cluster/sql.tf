resource "random_id" "dbpassword" {
  byte_length = 12
}

resource "google_sql_database_instance" "master" {
  provider         = google
  project          = var.project_id
  name             = var.db_master_name
  region           = data.terraform_remote_state.vpc.outputs.shared.default_region
  database_version = "POSTGRES_13"

  #depends_on = [
  #  "google_service_networking_connection.private_vpc_connection"
  #]

  settings {
    tier      = "db-f1-micro"
    disk_size = "10"
    disk_type = "PD_SSD"

    ip_configuration {
      ipv4_enabled    = false #  to prevent the db from getting a public IP
      private_network = data.terraform_remote_state.vpc.outputs.vpc_info.network_self_link
    }
  }
}

resource "google_sql_user" "db-user" {
  project  = var.project_id
  name     = "postgres"
  password = random_id.dbpassword.hex
  instance = google_sql_database_instance.master.name

  depends_on = [google_sql_database_instance.master]
}


# https://www.terraform.io/docs/providers/google/r/sql_database.html
resource "google_sql_database" "dpop" {
  name      = "dpop"
  project   = var.project_id
  instance  = google_sql_database_instance.master.name
  charset   = "UTF8"
  collation = "en_US.UTF8"

  depends_on = [
    google_sql_database_instance.master,
    google_sql_user.db-user
  ]
}
