resource "aws_kms_key" "this" {
  description         = "KMS key used to encrypt the CDS export bucket."
  enable_key_rotation = true
}

resource "aws_kms_alias" "this" {
  name          = "alias/${aws_s3_bucket.export.id}"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.this.id
  policy = data.aws_iam_policy_document.kms.json
}

data "aws_iam_policy_document" "kms" {
  #checkov:skip=CKV_AWS_109:Only assigning the kms:GenerateDataKey and kms:Decrypt permissions led to a 'you won't be able to manage the key once created' error
  #checkov:skip=CKV_AWS_111:Only assigning the kms:GenerateDataKey and kms:Decrypt permissions led to a 'you won't be able to manage the key once created' error
  #checkov:skip=CKV_AWS_356:Only assigning the kms:GenerateDataKey and kms:Decrypt permissions led to a 'you won't be able to manage the key once created' error
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.ecs_task_role_arn]
    }

    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]

    resources = [
      aws_kms_key.this.arn
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]
  }
}
