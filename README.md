# dpop-gcp-infra-tf

DPoP Terraform for GCP infrastructure

## Example of using `vpc` module

```tf
module "vpc" {
    source = "github.com/proven-id/dpop-gcp-infra-tf/vpc"
    
    org_id=251762102388
    region="us-central1"
    billing_account="01F94A-B15359-xxxx"
    route_to_internet="default-route-2abe1ef11cad4189"
    vpc_info={
        project_id   = "provenid"
        network_name = "provenid-net-dev"
        cidr         = "10.0.0.0/8"
    }
    vpc_subnets=[
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
    dns={
        zone       = "test.proveid.dev."
        api_domain = "api.test.proveid.dev."
        ui_domain  = "app.test.proveid.dev."
    }
}
```

## Example of using `cluster` module

```
module "cluster" {
  source = "github.com/proven-id/dpop-gcp-infra-tf/cluster"

  org_id                      = 251762102388
  region                      = "us-central1"
  project_id                  = "provenid"
  shared_vpc_project          = "provenid"
  project_service_account     = "project-service-account@provenid.iam.gserviceaccount.com"
  node_service_account        = "project-service-account@provenid.iam.gserviceaccount.com"
  cluster_name                = "provenid01"
  db_master_name              = "provenid"
  network                     = "provenid-net-dev"
  subnet                      = "provenid"
  vpc_terraform_bucket        = "proveid-test-terraform"
  vpc_terraform_prefix        = "test/proveid-vpc"
  machine_type                = "e2-standard-2"
}
```
