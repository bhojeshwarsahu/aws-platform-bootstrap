data "aws_iam_policy_document" "github_oidc_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.github_repository}:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_role" "github_bootstrap" {
  name = "${local.name_prefix}-github-bootstrap-role"

  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-github-bootstrap-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "administrator_access" {
  role       = aws_iam_role.github_bootstrap.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "github_infra_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:bhojeshwarsahu/aws-platform-infra:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_role" "github_infra" {
  name = "${local.name_prefix}-github-infra-role"

  assume_role_policy = data.aws_iam_policy_document.github_infra_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-github-infra-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "infra_administrator_access" {
  role       = aws_iam_role.github_infra.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}