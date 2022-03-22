variable "org_id" {
  type    = string
}

variable "billing_account" {
  type    = string
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

variable "vpc_info" {
  type = map(any)
  #default = {
  #  project_id   = "provenid-vpc"
  #  network_name = "provenid-net"
  #  cidr         = "10.0.0.0/8"
  #}
}

variable "dns" {
  type = map(any)
  #default = {
  #  zone       = "proveni.dev."
  #  api_domain = "api.proveni.dev."
  #  ui_domain  = "app.proveni.dev."
  #}
}

# Mapping of subnet names to the /16 that they will occupy.
# Examples:
#   25 => 10.25.0.0/16
#   107 => 10.107.0.0/16
#   183 => 10.183.0.0/16
# This range will get sliced up for k8s pods/services.
variable "vpc_subnets" {
  default = [
    {
      name         = "provenid-private"
      range        = "10.1.0.0/16"
      master_range = "172.16.1.0/24"
    },
    {
      name         = "provenid"
      range        = "10.2.0.0/16"
      master_range = "172.16.2.0/28"

      pod_range_name     = "provenid-pods"
      service_range_name = "provenid-services"
    },
  ]
}

variable "route_to_internet" {
  type    = string
  #default = "default-route-3d2bd121064096d8"
}

variable "dev_iam_group" { 
  default = "group:gcp-developers@proveid.dev" 
}

variable "se_iam_group" { 
  default = "group:gcp-security-admins@proveid.dev" 
}
