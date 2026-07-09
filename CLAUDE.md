# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Terraform that bootstraps the AWS account itself, before any other IaC or CI/CD pipeline can run. It creates:

- The S3 bucket + DynamoDB lock table + KMS key that Terraform state (including this repo's own state) is stored in ([s3.tf](s3.tf), [dynamodb.tf](dynamodb.tf), [kms.tf](kms.tf))
- A GitHub Actions OIDC provider ([oidc.tf](oidc.tf))
- IAM roles that GitHub Actions assumes via OIDC to run Terraform, in this repo and in the downstream `aws-platform-infra` repo ([iam.tf](iam.tf))

This is a chicken-and-egg repo: it must be applied once by hand (or with a privileged principal) before its own `backend.tf` remote state and OIDC role exist. **That first apply is the only manual step, ever** — after state is migrated to S3, every subsequent change to this repo (including to its own IAM roles) flows exclusively through the `terraform-plan`/`terraform-apply` GitHub Actions workflow. Don't reintroduce local/manual `terraform apply` against this state, and don't add anything that only works when run by a human (e.g. interactive prompts, local-only data sources) — the goal of this repo is zero manual work after the initial bootstrap.

Sibling repos referenced by this one (not present locally): `aws-platform-infra`, `aws-platform-gitops`, `aws-platform-apps`. This repo intentionally does not provision VPC/EKS/RDS/Redis/EFS/ArgoCD/monitoring — those live in `aws-platform-infra`.

## Commands

```bash
terraform init -input=false
terraform fmt -check -recursive
terraform validate
terraform plan  -input=false -var-file=prod.tfvars
terraform apply -input=false -auto-approve -var-file=prod.tfvars   # CI only, main branch
```

There is no test suite, build step, or app runtime — this is pure Terraform config. `prod.tfvars` and `terraform.tfvars` currently hold identical values; pass `-var-file=prod.tfvars` explicitly (matches CI) rather than relying on the auto-loaded `terraform.tfvars`.

Linting is done via [Trunk](.trunk/trunk.yaml) (`trunk check`), which runs `checkov`, `tflint`, `markdownlint`, `prettier`, `trufflehog`, and `git-diff-check` — checkov/tflint are the ones that matter for `.tf` changes.

## CI/CD (`.github/workflows/terraform.yml`)

Two jobs, gated by IAM role, not by branch protection alone:

- `terraform-plan`: runs on every push/PR, assumes `skilli-prod-github-bootstrap-plan-role` (read-only), runs fmt-check/init/validate/plan.
- `terraform-apply`: runs only on push to `main`, assumes `skilli-prod-github-bootstrap-role` (admin), runs apply. Depends on `terraform-plan` passing.

Both roles are defined in this same repo ([iam.tf](iam.tf)) — a change to the plan/deploy role's trust policy or permissions takes effect on the *next* workflow run, so a bad change to `github_bootstrap_plan`/`github_bootstrap` can lock CI out of its own AWS access. Treat edits to these two roles as higher-risk than other resources here.

## IAM role architecture

Four IAM roles, all assumed via the single GitHub OIDC provider (`aws_iam_openid_connect_provider.github` in [oidc.tf](oidc.tf)), differentiated by the `sub` claim condition in their trust policy:

| Role | Trust condition | Permissions | Used by |
|---|---|---|---|
| `github_bootstrap_plan` | `repo:<owner>/aws-platform-bootstrap:*` (any branch/PR) | `ReadOnlyAccess` | this repo's plan job |
| `github_bootstrap` | `repo:<owner>/aws-platform-bootstrap:ref:refs/heads/main` (main only) | `AdministratorAccess` | this repo's apply job |
| `github_infra_plan` | `repo:<owner>/aws-platform-infra:*` | `ReadOnlyAccess` | downstream infra repo's plan job |
| `github_infra` | `repo:<owner>/aws-platform-infra:ref:refs/heads/main` | `AdministratorAccess` | downstream infra repo's apply job |

Pattern to follow for any new consumer repo: a `*_plan` role scoped to `repo:...:*` with read-only access, and a deploy role scoped to `ref:refs/heads/main` with the permissions it actually needs. `github_repository` / `github_infra_repository` (built from `var.github_owner` in [locals.tf](locals.tf)) are the source of truth for which repo each pair trusts — add a new local + role pair rather than hardcoding repo names in a trust policy.

## State locking

State locking is native S3 locking (`use_lockfile = true` in [backend.tf](backend.tf), requires Terraform 1.10+) — there is no DynamoDB lock table. Don't add one; it would be dead infrastructure.

## OIDC thumbprint

The GitHub OIDC provider's thumbprint ([oidc.tf](oidc.tf)) is fetched at plan/apply time via a `tls_certificate` data source, not hardcoded — this was previously a placeholder value (`ffffff...`) that had been wrong since the repo's first commit. Keep it dynamic rather than reverting to a literal string; a stale thumbprint is exactly the kind of thing that silently breaks CI and forces a manual fix.

## Naming and tagging

`local.name_prefix` (`"${var.project_name}-${var.environment}"`, e.g. `skilli-prod`) prefixes every resource name — keep new resources consistent with this. `local.common_tags` (in [locals.tf](locals.tf)) is applied automatically via the AWS provider's `default_tags` block ([provider.tf](provider.tf)), so resources generally don't need to set tags themselves beyond a `Name` override.
