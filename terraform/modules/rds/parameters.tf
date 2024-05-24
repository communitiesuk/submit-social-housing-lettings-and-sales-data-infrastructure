resource "aws_ssm_parameter" "database_partial_connection_string" {
  name   = "DATABASE_PARTIAL_CONNECTION_STRING"
  key_id = aws_kms_key.ssm.arn
  type   = "SecureString"
  value  = "postgresql://${aws_db_instance.this.username}:${aws_db_instance.this.password}@${aws_db_instance.this.endpoint}"
}

resource "aws_kms_key" "ssm" {
  description         = "KMS key used to decrypt SSM parameters."
  enable_key_rotation = true
}

resource "aws_kms_alias" "ssm" {
  name          = "alias/${var.prefix}-rds-ssm-parameters"
  target_key_id = aws_kms_key.ssm.key_id
}

resource "aws_kms_key_policy" "ssm" {
  key_id = aws_kms_key.ssm.id
  policy = data.aws_iam_policy_document.kms_ssm.json
}

data "aws_iam_policy_document" "kms_ssm" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.ecs_task_execution_role_arn]
    }

    actions = ["kms:Decrypt"]

    resources = [aws_kms_key.ssm.arn]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["kms:*"]

    resources = [aws_kms_key.ssm.arn]
  }
}
