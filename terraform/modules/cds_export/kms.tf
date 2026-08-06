resource "aws_kms_key" "this" {
  description         = "KMS key used to encrypt/decrypt data in the CDS export bucket."
  enable_key_rotation = true
}

resource "aws_kms_alias" "this" {
  name          = "alias/${aws_s3_bucket.export.id}"
  target_key_id = aws_kms_key.this.key_id
}

locals {
  create_cds_azure_user_access = var.cds_azure_user_name != null
}

resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.this.id
  policy = data.aws_iam_policy_document.combined.json
}

# Terraform / AWS wouldn't intelligently combine policies applied to the key separately, so we use override_policy_documents to do this when necessary
data "aws_iam_policy_document" "combined" {
  override_policy_documents = concat(
    [data.aws_iam_policy_document.ecs_task_role.json],
    local.create_cds_role ? [data.aws_iam_policy_document.cds_role[0].json] : [],
    local.create_cds_azure_user_access ? [data.aws_iam_policy_document.cds_azure_user[0].json] : []
  )
}

data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    sid = "ECSTaskRoleEncrypt"
    principals {
      type        = "AWS"
      identifiers = [var.ecs_task_role_arn]
    }

    actions = [
      "kms:GenerateDataKey",
      "kms:Encrypt"
    ]

    resources = [aws_kms_key.this.arn]
  }

  statement {
    sid = "Root"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["kms:*"]

    resources = [aws_kms_key.this.arn]
  }
}

data "aws_iam_policy_document" "cds_azure_user" {
  count = local.create_cds_azure_user_access ? 1 : 0

  statement {
    sid = "CDSAzureUserDecrypt"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.cds_azure_user_name}"]
    }

    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]

    resources = [aws_kms_key.this.arn]
  }

  statement {
    sid = "Root"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["kms:*"]

    resources = [aws_kms_key.this.arn]
  }
}

data "aws_iam_policy_document" "cds_role" {
  count = local.create_cds_role ? 1 : 0

  statement {
    sid = "CDSRoleDecrypt"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.cds[0].arn]
    }

    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]

    resources = [aws_kms_key.this.arn]
  }

  statement {
    sid = "Root"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["kms:*"]

    resources = [aws_kms_key.this.arn]
  }
}
