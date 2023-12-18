[![Terraform](https://github.com/mdb/tf-workspaces-demo/actions/workflows/terraform.yaml/badge.svg?branch=main)](https://github.com/mdb/tf-workspaces-demo/actions/workflows/terraform.yaml)

# tf-workspaces-demo

**Problem statement:** You need to create and manage cloud infrastructure
landscapes across many different AWS account/region combinations targeting many
different logical environments (`dev`, `prod`, etc.).

How can a single, IaC configuration be used across all necessary account, region,
and environment combinations, expediting lead time creating new infrastructure
as new account/region/environment combinations reveal themselves as necessary?
How can the IaC be modeled to enforcing logically isolated failure domains and
uniformity, while also accommodating heterogeneity where necessary?

**Solution:** `tf-workspaces-demo` shows how Terraform's [workspace](https://developer.hashicorp.com/terraform/language/state/workspaces) feature -- used in concert with a robust workspace naming convention -- enables scalable [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) re-use patterns and logical infrastructure segmentation.

* Use GitHub Actions to plan (and apply) a single Terraform configuration to multiple [workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) across a dynamically generated [matrix](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs) of AWS account/region/environment combinations.
* Enable the creation of new environments in new regions by adding a single entry to `workspaces.json`.
* Bonus: leverage Terraform workspaces to dynamically create ephemeral
  pull-request-based dev and testing environments.

## Highlights

* Use a `${AWS_ACCOUNT_ID}_${AWS_REGION}_${ENV}` workspace naming scheme to
  logically segement Terraform actions (and [state](https://developer.hashicorp.com/terraform/language/state)) across AWS account/region/environment
  boundaries, ensuring sufficiently limited failure domains.
* Use the workspace naming convention to enabling DRY repeatability that accommodates
  per-workspace (or per-account, per-region, or per-environment) heterogeneity
  only where needed.
* Enable the low-friction creation of new infrastructure in new
  account/region/environment combinations by adding a single workspace entry to
  `workspaces.json`.
* Dynamically drive the creation of GitHub Actions matrix builds
* Use the `terraform.workspace` to impose an [allowed_account_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#allowed_account_ids) constraint on the AWS provider, such that an environment is never plan/apply'd to the wrong account.

**Disclaimers**

* `tf-workspaces-demo` is not an argument in favor of monolithic Terraform
  configurations; ideally, Terraform is subdivided across sufficiently (but not
  overly) granular projects, each serving different layers of infrastructure
  responsibility (networking, IAM, platform, application, etc.). Effective
  modeling of these layers across distinct Terraform projects is a separate art altogether :)
* For demo purposes, `tf-workspaces-demo` uses [localstack-persist](https://hub.docker.com/r/gresau/localstack-persist) as a local, mocked AWS. As such, no real AWS resources are created; instead, the demo focuses on illustrating high level Terraform patterns that are largely agnostic to the underlying infrastructure resources. However, the use of `localstack-persist` -- and the demo's need to persist `localstack` data across GitHub Actions jobs -- requires lotsa extra GitHub Actions workflow steps that wouldn't appear in a real world workflow targeting a real cloud provider. Try not to be too distracted by that :)

## Bonus highlights and callouts

While only peripherally relevant to the core problem statement, `tf-workspaces-demo`
demos some other fun stuff too.

* On pull requests, `plan`/`apply` to an ephemeral pull-request workspace;
  destroy that workspace if/when the pull request is closed or merged (and automate the
  creation of PR comments announcing these actions) (This also demonstrates how
  the `${AWS_ACCOUNT_ID}_${AWS_REGION}_${ENV}` workspace naming scheme accommodates
  additional, increasingly granular suffixes if/where needed, like
  `${AWS_ACCOUNT_ID}_${AWS_REGION}_${ENV}_pr-${PULL_REQUEST_ID}`).
* `tf-workspaces-demo` illustrates the use [localstack-persist](https://hub.docker.com/r/gresau/localstack-persist) to create a local mock AWS
* `tf-workspaces-demo` shows how persist `localstack-persist` data across GitHub Actions jobs using [actions/upload-artifact](https://github.com/actions/upload-artifact)
* Use a `Makefile` to wrap `terraform` commands, helping facilitate consistent (and documented) usage, independent of execution context (local vs. CI/CD, etc.)

See the source code comments for particular details and relevant callouts.

## Wanna learn more about Terraform workspaces?

* [Using Terraform Workspaces](https://mikeball.info/blog/using-terraform-workspaces/)
* [HashiCorp's Terraform Workspaces documentation](https://developer.hashicorp.com/terraform/language/state/workspaces)

## What about other tools?

* **What about [terragrunt](https://terragrunt.gruntwork.io/)?**

  In many contexts, [Terragrunt](https://terragrunt.gruntwork.io/) (and similar tools)
  are great. However, their use invites additional complexity (and additional questions about
  how best to structure IaC across account, region, and environment boundaries). Often,
  in my experience, Terraform workspaces are sufficient.
* **Don't [Terraform child modules](https://developer.hashicorp.com/terraform/language/modules#child-modules) enable reuse?**

  Generally, Terraform child modules aspire to solve a bit of a different problem: while
  workspaces facilitate the application of a Terraform project against multiple
  target contexts, provider configurations, and aginst isolated [states](https://developer.hashicorp.com/terraform/language/state), child modules are generic
  abstractions of opinionated Terraform "recipes." Modules often target specific
  resources (or combinations of resources), but are largely agnostic to the
  surrounding context. These child modules can be used and applied within parent Terraform
  projects, though they cannot be applied independently; they have no project-specific [state](https://developer.hashicorp.com/terraform/language/state) and [provider](https://developer.hashicorp.com/terraform/language/providers) configuration. As such, child modules enable reuse and [composability](https://developer.hashicorp.com/terraform/language/modules/develop/composition) -- and/or enforce best practices governance -- along different dimensions.
