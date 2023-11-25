locals {
  workspace_parts = split("_", terraform.workspace)

  account_id = local.workspace_parts[0]

  region = local.workspace_parts[1]
}
