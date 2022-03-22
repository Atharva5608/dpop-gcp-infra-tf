module "k8s-provenid" {
  source                  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version                 = "~> 15.0"
  project_id              = var.project_id
  name                    = var.cluster_name
  regional                = true
  region                  = data.terraform_remote_state.vpc.outputs.shared.default_region
  network_project_id      = data.terraform_remote_state.vpc.outputs.vpc_info.svpc_host_project_id
  network                 = data.terraform_remote_state.vpc.outputs.vpc_info.network_name
  subnetwork              = var.subnet
  ip_range_pods           = data.google_compute_subnetwork.gke_subnet.secondary_ip_range[0].range_name
  ip_range_services       = data.google_compute_subnetwork.gke_subnet.secondary_ip_range[1].range_name
  service_account         = "create"
  enable_private_endpoint = false
  enable_private_nodes    = true

  #TODO:
  #master_ipv4_cidr_block     = data.google_compute_subnetwork.gke_subnet.ip_cidr_range
  logging_service            = "logging.googleapis.com/kubernetes"
  monitoring_service         = "monitoring.googleapis.com/kubernetes"
  remove_default_node_pool   = true
  horizontal_pod_autoscaling = true
  release_channel            = "REGULAR" # Approximate upgrade cadence : Multiple per month
  kubernetes_version         = ""

  enable_shielded_nodes = false
  node_metadata         = "GKE_METADATA_SERVER"
  identity_namespace    = "${var.project_id}.svc.id.goog"
  grant_registry_access = true

  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "World"
    },
  ]

  # The {min,max,initial_node}_counts below are per zone. 
  # This cluster runs in 3 zones, so multiply by 3
  # for the real node count.
  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = var.machine_type
      min_count          = 1
      max_count          = 2
      initial_node_count = 1
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false,
      service_account    = var.node_service_account
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    default-node-pool = []
  }

  node_pools_metadata = {
    all               = {}
    default-node-pool = {}
  }

  node_pools_labels = {
    all               = {}
    default-node-pool = {}
  }

  node_pools_taints = {
    all               = []
    default-node-pool = []
  }

  node_pools_tags = {
    all               = []
    default-node-pool = []
  }
}

resource "google_compute_firewall" "k8s-provenid-master-to-kubelets" {
  name    = "k8s-provenid-master-to-kubelets"
  project = data.terraform_remote_state.vpc.outputs.vpc_info.svpc_host_project_id
  network = data.terraform_remote_state.vpc.outputs.vpc_info.network_name

  description = "GKE master to kubelets"

  source_ranges = [for s in data.terraform_remote_state.vpc.outputs.vpc_info.vpc_subnets : s.master_range if s.name == var.subnet]

  allow {
    protocol = "tcp"
    ports    = ["6443", "8443"]
  }
}

resource "google_project_iam_member" "role-binding-host-agent" {
  project = var.project_id
  role    = "roles/container.serviceAgent"
  member  = "serviceAccount:${module.k8s-provenid.service_account}"
}

resource "google_project_iam_member" "role-binding-logs" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${module.k8s-provenid.service_account}"
}

resource "google_project_iam_member" "role-binding-metrics" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${module.k8s-provenid.service_account}"
}

# NOTE: this fails on the first run.

provider "kubernetes" {
  cluster_ca_certificate = base64decode(module.k8s-provenid.ca_certificate)
  host                   = "https://${module.k8s-provenid.endpoint}"
  token                  = data.google_client_config.current.access_token
}

resource "kubernetes_namespace" "provenid" {
  metadata {
    name = "provenid"
  }
}

resource "kubernetes_secret" "sql-conn-dpop" {
  metadata {
    name      = "sql-conn-dpop"
    namespace = kubernetes_namespace.provenid.metadata[0].name
  }

  data = {
    "sql-conn-dpop.txt" = "host=${google_sql_database_instance.master.ip_address.0.ip_address} port=5432 user=postgres password=${random_id.dbpassword.hex} sslmode=disable dbname=dpop"
    POSTGRES_PASSWORD     = random_id.dbpassword.hex
  }
}
