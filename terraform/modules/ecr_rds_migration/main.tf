terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

#tfsec:ignore:aws-ecr-repository-customer-key:encryption using KMS CMK not required
resource "aws_ecr_repository" "db_migration" {
  #checkov:skip=CKV_AWS_51:mutable image tags preferred as we always want the latest image and don't need to track previous ones
  #checkov:skip=CKV_AWS_136:encryption using KMS not required
  name                 = "db-migration"
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

resource "aws_ecr_repository_policy" "db_migration" {
  repository = aws_ecr_repository.db_migration.name
  policy     = data.aws_iam_policy_document.this.json
}