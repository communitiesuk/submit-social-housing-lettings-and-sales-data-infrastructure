terraform {
  required_version = "~>1.5.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

#tfsec:ignore:aws-ecr-enforce-immutable-repository:we require mutable tags for our current deployment process
#tfsec:ignore:aws-ecr-repository-customer-key:encryption using KMS CMK not required
resource "aws_ecr_repository" "this" {
  #checkov:skip=CKV_AWS_51:we require mutable tags for our current deployment process
  #checkov:skip=CKV_AWS_136:encryption using KMS not required
  name                 = "core-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}