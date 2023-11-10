locals {
  repositories = {
    "application"    = var.application_repo
    "infrastructure" = var.infrastructure_repo
  }
}

data "aws_iam_policy_document" "repo_assume_role" {
  for_each = local.repositories

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.meta_account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${each.value}:*"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

moved {
  from = data.aws_iam_policy_document.app_repo_assume_role
  to   = data.aws_iam_policy_document.repo_assume_role["application"]
}

resource "aws_iam_role" "repo" {
  for_each = local.repositories

  name               = "core-${each.key}-repo"
  assume_role_policy = data.aws_iam_policy_document.repo_assume_role[each.key].json
}

moved {
  from = aws_iam_role.app_repo
  to   = aws_iam_role.repo["application"]
}

#tfsec:ignore:aws-iam-no-policy-wildcards: This is used permissively in what this role can do, not who is allowed to assume this role
data "aws_iam_policy_document" "allow_assuming_roles" {
  #checkov:skip=CKV_AWS_107: This is a necessary part of this action
  #checkov:skip=CKV_AWS_356: We allow our role to assume any other that allows it
  #checkov:skip=CKV_AWS_111: Allowing our role to tag any sessions is fine
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "allow_assuming_roles" {
  name   = "allow-assuming-roles"
  policy = data.aws_iam_policy_document.allow_assuming_roles.json
}

resource "aws_iam_role_policy_attachment" "allow_assuming_roles" {
  for_each = local.repositories

  role       = aws_iam_role.repo[each.key].name
  policy_arn = aws_iam_policy.allow_assuming_roles.arn
}

moved {
  from = aws_iam_role_policy_attachment.allow_assuming_roles
  to   = aws_iam_role_policy_attachment.allow_assuming_roles["application"]
}