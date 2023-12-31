#tfsec:ignore:aws-ecr-repository-customer-key:encryption using KMS CMK not required
resource "aws_ecr_repository" "core" {
  #checkov:skip=CKV_AWS_136:encryption using KMS not required
  name                 = "core"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.allow_access_by_roles
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
    ]
  }
}

resource "aws_ecr_repository_policy" "core" {
  repository = aws_ecr_repository.core.name
  policy     = data.aws_iam_policy_document.this.json
}