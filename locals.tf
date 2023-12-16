locals {
  workspace_parts = split("_", terraform.workspace)

  account_id = local.workspace_parts[0]

  region = local.workspace_parts[1]

  env = local.workspace_parts[2]

  terraform_data_count_per_env = {
    prod = 2
  }

  # Use an explicit env-specific count if one has been defined; otherwise
  # default to 1.
  # This seeks to demonstrate how workspace naming can accommodate environment-specific
  # heterogeneity spanning multiple workspaces with minimal logic, only where
  # needed and without polluting a Terraform configuration's public interface
  # via excessive variables.
  terraform_data_count = try(local.terraform_data_count_per_env[local.env], 1)
}
