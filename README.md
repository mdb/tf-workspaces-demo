# tf-workspaces-demo

`tf-workspaces-demo` seeks to show how Terraform's [workspace](https://developer.hashicorp.com/terraform/language/state/workspaces) feature enables [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) re-use patterns, abstracing and minimizing (or omitting, entirely) the need to maintain unique and redundant Terraform IaC accross AWS account, region, and environment combinations.

* Use GitHub Actions to plan and apply a single Terraform configuration to multiple [workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) across a dynamically generated [matrix](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs) of AWS account/region/environment combinations.
* Enable the creation of new environments in new regions by adding a single entry to `workspaces.json`

## Highlights

* use a `${AWS_ACCOUNT}_${AWS_REGION}_${ENV}` workspace naming scheme to
  logically segement Terraform states across AWS account/region/environment
  boundaries, ensuring sufficiently limited failure domains, while also enabling
  DRY repeatability that accommodates per-workspace (or per-account, per-region,
  or per-environment) heterogeneity only where needed.
* use the `terraform.workspace` to impose an [allowed_account_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#allowed_account_ids) constraint on the AWS provider, such that an environment is never plan/apply'd to the wrong account.
* enable the low-friction creation of new infrastructure in new account/region/environment combinations by adding a single workspace entry to `workspaces.json`
* Bonus: `tf-workspaces-demo` illustrates the use [localstack-persist](https://hub.docker.com/r/gresau/localstack-persist) to create a local "mock" AWS
* Bonus: `tf-workspaces-demo` shows how persist `localstack-persist` data across GitHub Actions jobs using [actions/upload-artifact](https://github.com/actions/upload-artifact)
* Bonus: use a `Makefile` to wrap `terraform` commands, helping facilitate consistent (and documented) usage, independent of execution context (local vs. CI/CD, etc.)

## Wanna learn more about Terraform workspaces?

* [Using Terraform Workspaces](https://mikeball.info/blog/using-terraform-workspaces/)
* [HashiCorp's Terraform Workspaces documentation](https://developer.hashicorp.com/terraform/language/state/workspaces)
