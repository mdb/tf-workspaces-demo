terraform {
  required_version = "1.5.0"

  # Terraform workspaces support a single S3 backend configuration spanning all
  # workspaces, enabling re-use of a single Terraform project configuration
  # across multiple workspace contexts.
  #
  # Terraform automatically saves each workspace's state to a distinct
  # workspace object path:
  # s3://${BUCKET}/env:/${terraform.workspace}/${KEY}
  #
  # If no workspace is specified, Terraform uses the 'default' workspace and saves
  # the state to:
  # s3://${BUCKET}/${KEY}
  backend "s3" {
    # Often, IME, it's useful to home this S3 bucket -- and thereby all
    # workspaces' Terraform state files -- in a central "management" AWS account.
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
