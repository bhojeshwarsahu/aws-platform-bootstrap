#############################################
# BOOTSTRAP PLAN ROLE
#############################################

data "aws_iam_policy_document" "github_bootstrap_plan_assume_role" {
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
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${local.github_repository}:*"
      ]
    }
  }
}

resource "aws_iam_role" "github_bootstrap_plan" {
  name = "${local.name_prefix}-github-bootstrap-plan-role"

  assume_role_policy = data.aws_iam_policy_document.github_bootstrap_plan_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-github-bootstrap-plan-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "bootstrap_plan_readonly" {
  role       = aws_iam_role.github_bootstrap_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

#############################################
# BOOTSTRAP DEPLOY ROLE
#############################################

data "aws_iam_policy_document" "github_bootstrap_deploy_assume_role" {
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

  assume_role_policy = data.aws_iam_policy_document.github_bootstrap_deploy_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-github-bootstrap-role"
    }
  )
}

# resource "aws_iam_role_policy_attachment" "administrator_access" {
#   role       = aws_iam_role.github_bootstrap.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }
resource "aws_iam_role_policy_attachment" "bootstrap_admin" {
  role       = aws_iam_role.github_bootstrap.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
#############################################
# INFRA PLAN ROLE
#############################################

data "aws_iam_policy_document" "github_infra_plan_assume_role" {
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
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${local.github_infra_repository}:*"
      ]
    }
  }
}

resource "aws_iam_role" "github_infra_plan" {
  name = "${local.name_prefix}-github-infra-plan-role"

  assume_role_policy = data.aws_iam_policy_document.github_infra_plan_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-github-infra-plan-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "infra_plan_readonly" {
  role       = aws_iam_role.github_infra_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

#############################################
# INFRA DEPLOY ROLE
#############################################

data "aws_iam_policy_document" "github_infra_deploy_assume_role" {
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
        "repo:${local.github_infra_repository}:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_role" "github_infra" {
  name = "${local.name_prefix}-github-infra-role"

  assume_role_policy = data.aws_iam_policy_document.github_infra_deploy_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-github-infra-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "infra_admin" {
  role       = aws_iam_role.github_infra.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}