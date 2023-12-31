resource "aws_kms_key" "this" {
  description         = "KMS key used to decrypt SSM parameters."
  enable_key_rotation = true
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.prefix}-app-ssm-parameters"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.this.id
  policy = data.aws_iam_policy_document.kms.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.ecs_task_execution_role_arn]
    }

    actions = ["kms:Decrypt"]

    resources = [aws_kms_key.this.arn]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["kms:*"]

    resources = [aws_kms_key.this.arn]
  }
}
