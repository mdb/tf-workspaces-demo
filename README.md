[![Terraform](https://github.com/mdb/tf-workspaces-demo/actions/workflows/terraform.yaml/badge.svg?branch=main)](https://github.com/mdb/tf-workspaces-demo/actions/workflows/terraform.yaml)

# tf-workspaces-demo

**Problem statement:** You need to create and manage cloud infrastructure
landscapes across many different AWS account/region combinations targeting
different logical environments (`dev`, `prod`, etc.).

How can a single, Terraform project be used across all necessary account, region,
and environment combinations? How can the IaC be modeled to enforce security best
practices, uniformity, and logically isolated failure domains, while also
accommodating intentional heterogeneity?

**Solution:** In my experience, Terraform's [workspace](https://developer.hashicorp.com/terraform/language/state/workspaces) feature -- used in concert with a compound `${AWS_ACCOUNT_ID}_${AWS_REGION}_${ENV}`-based workspace naming convention -- enables scalable, [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) re-use patterns, and logical infrastructure segmentation, reducing toil and lead time.

`tf-workspaces-demo` offers a reference implementation.

## Highlights

* Use a `${AWS_ACCOUNT_ID}_${AWS_REGION}_${ENV}`-compound workspace naming scheme to
  logically segment Terraform operations (and [state](https://developer.hashicorp.com/terraform/language/state)) across AWS account/region/environment
  boundaries, ensuring infrastructure redundancy across sufficiently limited failure domains.
* Ensure uniformity across workspaces, while also accommodating intentional per-workspace
  (or per-account, per-region, or per-environment) heterogeneity if/where needed.
* Enable the low-friction creation of new infrastructure in new
  account/region/environment combinations by adding a single workspace entry to
  `workspaces.json`.
* Dynamically drive the creation of GitHub Actions matrix builds to `plan`/`apply`,
  Terraforom, ensuring CI/CD automation elastically scales and contracts as
  workspaces are created and/or decommissioned.
* Use the `terraform.workspace` to impose an [allowed_account_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#allowed_account_ids) constraint on the AWS provider, such that an environment is never `plan`/`apply`'d to the wrong account.
* Bonus: leverage Terraform workspaces to dynamically create ephemeral pull-request-based
  development and testing environments.
    * See [PR 16](https://github.com/mdb/tf-workspaces-demo/pull/16) and its
      associated [GitHub Actions workflow](https://github.com/mdb/tf-workspaces-demo/actions/runs/7287133745) as an
      example.
    * See [PR 15](https://github.com/mdb/tf-workspaces-demo/pull/15) and its
      [environment's destruction](https://github.com/mdb/tf-workspaces-demo/actions/runs/7275088524) as an
      example of the automated destruction of an ephemeral environment after
      a PR is closed or merged.

**Disclaimers**

* It's often useful to subdivide IaC across **_responsibility_**-based projects,
  each serving a different "layer" of infrastructure purpose (vs. problematically large, sprawling
  "monolithic" Terraform projects). For example, foundational infrastructure,
  such as VPC and networking configuration, may be managed in separate Terraform project(s)
  than higher level platform infrastructure, such as Kubernetes clusters.
  `tf-workspaces-demo` glosses over this, focusing instead on the effective
  use of Terraform workspace conventions _within_ projects. Effective modeling
  of responsibility layers across distinct Terraform projects is a separate art
  altogether ;)
* To decouple the demo from real-world AWS dependencies, `tf-workspaces-demo` uses [localstack-persist](https://hub.docker.com/r/gresau/localstack-persist) as a local, mocked AWS. No real AWS resources are created; instead, the demo focuses on illustrating high level Terraform/AWS patterns that are largely agnostic to the specific AWS resources under management.
* The use of `localstack-persist` -- and the demo's need to persist `localstack` data across GitHub Actions jobs -- requires lotsa extra GitHub Actions workflow monkey business that wouldn't appear in a real world workflow targeting a real cloud provider. Try not to be too distracted by that :)
* `tf-workspaces-demo`'s GitHub Actions workflow is **not** intended as the
  canonical design universally applicable to all projects and contexts. Depending on
  needs, it may be attractive to structure a project's CI/CD differently. For example,
  there could be distinct jobs -- or even separate workflows, entirely -- targeting `dev`
  and `prod` (each composed of per-workspace parallelized matrix builds), such that
  CI/CD parallelizes operations within the same environment, while still ensuring
  per-workspace Terraform operations against `prod` hinge on `dev` operations' success.
  Additionally, the workflow(s) could be enhanced with additional steps and
  fanciness: [terratest](https://terratest.gruntwork.io/) tests, [OPX automated plan analysis](https://mikeball.info/blog/terraform-plan-validation-with-open-policy-agent/), automated
  pull request commenting reporting `plan` output, etc.

## Bonus highlights and callouts

While only peripherally relevant to the core problem statement, `tf-workspaces-demo`
demos some other fun stuff too.

* On pull requests, `plan`/`apply` to an ephemeral pull-request workspace;
  destroy that workspace if/when the pull request is closed or merged (and automate the
  creation of PR comments announcing these actions) (This also demonstrates how
  the `${AWS_ACCOUNT_ID}_${AWS_REGION}_${ENV}` workspace naming scheme accommodates
  additional, increasingly granular suffixes if/where needed, like
  `${AWS_ACCOUNT_ID}_${AWS_REGION}_${ENV}_pr-${PULL_REQUEST_ID}`).
* [localstack-persist](https://hub.docker.com/r/gresau/localstack-persist) is used to
  create a local mock AWS, mostly to decouple `tf-workspace-demo` from real AWS dependencies,
  while still illustrating some AWS/Terraform design patterns. Zooming out, though,
  `localstack` is useful for demos like `tf-workspaces-demo`, but also useful in
  development and testing real Terraform projects and modules, depending on
  context.
* `tf-workspaces-demo` uses [actions/upload-artifact](https://github.com/actions/upload-artifact)
  in a kinda-fun-but-maybe-hacky way to persist `localstack-persist` spanning multiple
  GitHub Actions jobs. This is a bit unusual; try not to be too _too_
  distracted.
* By imposing a `strategy.max-parallel: 1` on the GitHub Actions matrix build,
  Terraform actions are invoked serially against each workspace in the order in
  which workspaces are listed in `workspaces.json`. This means an error
  applying to a `dev` workspace fails the build before any Terraform action is taken
  against `prod` workspaces.
* `tf-workspaces-demo`'s `docker-compose.yaml` shows how to establish a
  `localstack`-based local AWS environment, pre-seeded with an S3 bucket for use
  persisting [Terraform state to S3](https://developer.hashicorp.com/terraform/language/state/remote), as
  well as a DynamoDB table for use enforcing [Terraform state locking](https://developer.hashicorp.com/terraform/language/state/locking)

See the source code comments for particular details and relevant callouts.

## Wanna learn more about Terraform workspaces?

* [Using Terraform Workspaces](https://mikeball.info/blog/using-terraform-workspaces/)
* [HashiCorp's Terraform Workspaces documentation](https://developer.hashicorp.com/terraform/language/state/workspaces)

## What about other tools/techniques?

* **What about [terragrunt](https://terragrunt.gruntwork.io/)?**

  In many contexts, [Terragrunt](https://terragrunt.gruntwork.io/) (and similar tools)
  are great. However, their use invites additional complexity (and additional questions about
  how best to structure IaC across account, region, and environment boundaries). Often,
  in my experience, Terraform workspaces are sufficient.
* **Don't [Terraform child modules](https://developer.hashicorp.com/terraform/language/modules#child-modules) enable DRY reuse?**

  Generally, Terraform child modules and workspaces address slightly different problems and are not mutually exclusive. While
  workspaces facilitate the application of a Terraform project against multiple
  target contexts, provider configurations, and against isolated [states](https://developer.hashicorp.com/terraform/language/state), child modules are more simply generic
  abstractions of opinionated Terraform "recipes." Modules often target specific
  resources (or combinations of resources), but are largely agnostic to the
  surrounding context. Child modules can be used and applied within parent Terraform
  projects, though they cannot be applied independently; they have no project-specific [state](https://developer.hashicorp.com/terraform/language/state) and [provider](https://developer.hashicorp.com/terraform/language/providers) configuration. As such, child modules enable reuse and [composability](https://developer.hashicorp.com/terraform/language/modules/develop/composition) -- and/or enforce best practices governance -- along different dimensions of concern.

* **Couldn't `region` be an [input variable](https://developer.hashicorp.com/terraform/language/values/variables)?**

  Rather than being encoded in the compound workspace naming convention, the
  Terraform project could utilize a `var.region` input variable, yes. However,
  this would lead to two problems:
    1. Workspace naming collision. For example, `123_dev`'s `us-east-1` and `123_dev`'s `us-west-2` deployments would no longer have unique workspace names.
    2. Workspace S3 state collision. For example, Terraform would attempt to use `s3://${BUCKET}/env:/123_dev/terraform.tfstate` for both `123_dev`'s `us-east-1` and `123_dev`'s `us-west-2` applications.
