terraform {
  required_version = "1.5.0"

  // Terraform workspaces assume a single S3 backend configuration spanning all
  // workspaces, enabling re-use of a single Terraform project configuration
  // across multiple workspace contexts.
  // Terraform automatically saves each workspace's state to a distinct
  // workspace object path:
  // ${BUCKET}/env:/${terraform.workspace}/terraform.tfstate
  backend "s3" {
    bucket                      = "tf-workspaces-demo"
    key                         = "terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "http://localhost.localstack.cloud:4566"
    sts_endpoint                = "http://localhost:4566"
    force_path_style            = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    access_key                  = "fake"
    secret_key                  = "fake"
  }
}
