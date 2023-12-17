# Via Terraform locals, workspace-specific logic can be triggered without
# leaking that logic beyond the Terraform project itself and complicating the
# Terraform configuration's public interface via excessive variables whose
# values must be determined via wrapper scripting and orchestration outside of
# Terraform.
#
# As a convention, all the Terraform configuration's conditional logic may live
# here, in a consolidated, easily-discoverable location within locals.tf.
# Configuration elsewhere in the project may use these locals, but doesn't need
# to repeat their logic in non-obvious dark corners of the project.
locals {
  workspace_parts = split("_", terraform.workspace)

  account_id = local.workspace_parts[0]

  region = local.workspace_parts[1]

  env = local.workspace_parts[2]

  # By creating a per-env allow list of accounts, the Terraform configuration
  # itself can guard against instances where a workspace targets and undesired
  # and problematic env/account combination, such as the use of a production
  # account to create a dev environment:
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#allowed_account_ids
  supported_accounts_per_env = {
    prod = ["123"]
    dev  = ["456"]
  }

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
