# output "terraform_state_bucket" {
#   value = aws_s3_bucket.terraform_state.bucket
# }
output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "github_bootstrap_role_arn" {
  value = aws_iam_role.github_bootstrap.arn
}

output "github_infra_role_arn" {
  value = aws_iam_role.github_infra.arn
}