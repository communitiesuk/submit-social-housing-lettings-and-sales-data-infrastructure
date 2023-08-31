data "aws_iam_policy_document" "app_repo_assume_role" {
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
      test     = "StringEquals"
      values   = ["repo:${var.application_repo}:*"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

resource "aws_iam_role" "app_repo" {
  name               = "core-application-repo"
  assume_role_policy = data.aws_iam_policy_document.app_repo_assume_role.json
}

data "aws_iam_policy_document" "push_images" {
  statement {
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]
    resources = [var.ecr_arn]
    effect    = "Allow"
  }

  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "push_images" {
  name   = "push-ecr-images"
  policy = data.aws_iam_policy_document.push_images.json
}

resource "aws_iam_role_policy_attachment" "app_repo_push_images" {
  role       = aws_iam_role.app_repo
  policy_arn = aws_iam_policy.push_images
}