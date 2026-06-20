locals {
  name_prefix       = "${var.project_name}-${var.environment}"
  account_id        = data.aws_caller_identity.current.account_id
  github_repository = "${var.github_owner}/aws-platform-bootstrap"
  github_infra_repository = "${var.github_owner}/aws-platform-infra"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Repository  = "aws-platform-bootstrap"
  }

  terraform_state_bucket = "${local.name_prefix}-${local.account_id}-tf-state"

  # terraform_lock_table = "${local.name_prefix}-tf-lock"

  kms_alias = "alias/${local.name_prefix}-tf-state"
}