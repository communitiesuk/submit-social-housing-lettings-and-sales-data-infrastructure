terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

#tfsec:ignore:aws-ecr-enforce-immutable-repository:mutable images preferred
#tfsec:ignore:aws-ecr-repository-customer-key:encryption using KMS CMK not required
#tfsec:ignore:aws-ecr-enforce-immutable-repository: For migration purposes, we accept mutable image tags
resource "aws_ecr_repository" "this" {
  #checkov:skip=CKV_AWS_51:mutable image tags preferred as we always want the latest image and don't need to track previous ones
  #checkov:skip=CKV_AWS_136:encryption using KMS not required
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

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

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = data.aws_iam_policy_document.this.json
}
