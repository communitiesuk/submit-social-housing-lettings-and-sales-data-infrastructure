resource "aws_kms_key" "performance_insights" {
  count = var.use_customer_managed_key_for_performance_insights ? 1 : 0

  description         = "KMS key used for db performance insights."
  enable_key_rotation = true
}

resource "aws_kms_alias" "performance_insights" {
  count = var.use_customer_managed_key_for_performance_insights ? 1 : 0

  name          = "alias/${var.prefix}-rds-performance-insights"
  target_key_id = aws_kms_key.performance_insights[0].key_id
}

resource "aws_kms_key_policy" "performance_insights" {
  count = var.use_customer_managed_key_for_performance_insights ? 1 : 0

  key_id = aws_kms_key.performance_insights[0].id
  policy = data.aws_iam_policy_document.kms_performance_insights[0].json
}

data "aws_iam_policy_document" "kms_performance_insights" {
  count = var.use_customer_managed_key_for_performance_insights ? 1 : 0

  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["kms:*"]

    resources = [aws_kms_key.performance_insights[0].arn]
  }
}
