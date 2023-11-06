#tfsec:ignore:aws-ecr-enforce-immutable-repository
#For ease we allow mutable tags here, given we're expecting to manually push and immediately run
resource "aws_ecr_repository" "this" {
  #checkov:skip=CKV_AWS_51 (mutable tags, see above)
  name                 = "core-performance-testing"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.this.arn
  }
}