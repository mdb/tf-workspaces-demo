# bootstrap

This directory homes a basic Terraform configuration for bootstrapping the
`localstack` environment with:

* a `tf-workspaces-demo` S3 bucket for use persisting [Terraform state to S3](https://developer.hashicorp.com/terraform/language/state/remote)
* a `terraform-lock` DynamoDB table for use enforcing [Terraform state locking](https://developer.hashicorp.com/terraform/language/state/locking)
