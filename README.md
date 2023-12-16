# tf-workspaces-demo

Use GitHub Actions to plan and apply a single Terraform configuration to multiple [workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) across a dynamically generated [matrix](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs).

## Bonus

* use [localstack-persist](https://hub.docker.com/r/gresau/localstack-persist) to create a local "mock" AWS
* persist `localstack-persist` data across GitHub Actions jobs using [actions/upload-artifact](https://github.com/actions/upload-artifact)
* use a `${AWS_ACCOUNT}_${AWS_REGION}_${ENV}` workspace naming scheme to
  logically segement Terraform states across account/region/environment
  boundaries, ensuring sufficiently limited failure domains, while also enabling
  DRY repeatability that accommodates per-workspace heterogeneity only where
  needed.

## Wanna learn more about Terraform workspaces?

* [Using Terraform Workspaces](https://mikeball.info/blog/using-terraform-workspaces/)
* [HashiCorp's Terraform Workspaces documentation](https://developer.hashicorp.com/terraform/language/state/workspaces)
