resource "terraform_data" "workspace" {
  count = local.terraform_data_count

  input = terraform.workspace
}
