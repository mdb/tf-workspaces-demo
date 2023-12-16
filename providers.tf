# Conditionally configure the aws provider based on the terraform.workspace's
# account ID part.
provider "aws" {
  region = local.region

  # Ensure an environment is never plan/apply'd against the wrong account.
  allowed_account_ids = [local.supported_accounts_per_env[local.env]]

  assume_role {
    # Dynamically assume the desired role based on the targeted account.
    role_arn = "arn:aws:iam::${local.account_id}:role/some-role"
  }
}
