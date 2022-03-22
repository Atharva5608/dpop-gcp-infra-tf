variable "org_id" {
  type    = string
}

variable "project_id" {
  type        = string
  description = "Project ID in which the cluster needs to be deployed"
}

variable "region" {
  type        = string
  description = "Region in which the cluster needs to be deployed"
  default     = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE cluster"
}

variable "project_service_account" {
  type        = string
  description = "Email of the Project service account"
}

variable "db_master_name" {
  type        = string
  description = "SQL name"
}

variable "shared_vpc_project" {
  type        = string
  description = "Name of the project hosting the shared VPC for GKE cluster"
}

variable "network" {
  type        = string
  description = "The GCP network to attach the k8s cluster to"
}

variable "subnet" {
  type        = string
  description = "The subnetwork to deploy the k8s cluster into"
}

variable "machine_type" {
  type        = string
  description = "The machine type used by nodes in the node pool"

  default = "n1-standard-1"
}

variable "num_of_local_ssds_per_node" {
  type        = string
  description = "Number of local SSDs to attach to each node"

  default = 1
}

variable "initial_node_count" {
  type        = string
  description = "Initial number of nodes to bring up in each zone before autoscaling kicks in"

  default = 1
}

# Ref: https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-autoscaler
variable "max_node_count" {
  type        = string
  description = "Max number of nodes per zone"

  default = 1
}

variable "max_pods_per_node" {
  type        = string
  description = "Maximum number of pods each node can possess (note that GKE assigns a subnet twice the size of this variable)"

  default = 4
}

variable "node_config_oauth_scopes" {
  type        = list(any)
  description = "Scopes for authorized node activity (the default is mandatory for storage and logging purposes)"

  default = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/sqlservice.admin",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/trace.append",
  ]
}

variable "autoscaling" {
  type        = string
  description = "If true, autoscaling will be turned on for the GKE cluster (the min node count will be 1 and the max node count will be the initial_node_count variable)"

  default = "true"
}

variable "node_service_account" {
  type        = string
  description = "Service account to assign to nodes to use"
}

variable "additional_master_authorized_cidr_blocks" {
  type        = list(any)
  description = "Add your own additional whitelists here"

  default = []
}

variable "tags" {
  type        = list(any)
  description = "Network tags that allow mapping to corresponding firewall rules"

  default = []
}

variable "cluster_create_timeout" {
  type        = string
  description = "Timeout for cluster creation (can be long for large clusters)"

  default = "60m"
}

variable "cluster_update_timeout" {
  type        = string
  description = "Rolling updates of the master and nodes (if done one-at-a-time) can take a long time"

  default = "60m"
}

variable "cluster_delete_timeout" {
  type        = string
  description = "Timeout for cluster destruction (can be long for large clusters)"

  default = "60m"
}

variable "write_gke_credentials_to_vault" {
  type        = string
  description = "If true, GKE cluster credentials will be written to vault under kubernetes_cluster_credentials_vault_path"

  default = "false"
}

variable "kubernetes_cluster_credentials_vault_path" {
  type        = string
  description = "The vault path under which the Kubernetes keys will be stored (must set this variable and set write_gke_credentials_to_vault to true)"

  default = ""
}

variable "vpc_terraform_bucket" {
  type        = string
}

variable "vpc_terraform_prefix" {
  type        = string
}
