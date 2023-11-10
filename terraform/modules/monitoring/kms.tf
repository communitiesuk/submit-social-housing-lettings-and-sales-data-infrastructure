resource "aws_kms_key" "this" {
  count = var.create_email_subscription ? 1 : 0

  description         = "KMS key used to decrypt the Secrets Manager secrets."
  enable_key_rotation = true
}

resource "aws_kms_alias" "this" {
  count = var.create_email_subscription ? 1 : 0

  name          = "alias/${var.prefix}-monitoring-secretsmanager-secrets"
  target_key_id = aws_kms_key.this[0].key_id
}

resource "aws_kms_key_policy" "this" {
  count = var.create_email_subscription ? 1 : 0

  key_id = aws_kms_key.this[0].id
  policy = data.aws_iam_policy_document.kms[0].json
}

data "aws_iam_policy_document" "kms" {
  count = var.create_email_subscription ? 1 : 0

  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["kms:*"]

    resources = [aws_kms_key.this[0].arn]
  }
}
