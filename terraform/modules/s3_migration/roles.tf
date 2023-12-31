data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  for_each = var.buckets

  name               = "${var.prefix}-${each.key}-s3-migration-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "task_execution_managed_policy" {
  for_each = var.buckets

  role       = aws_iam_role.task_execution[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "allow_secrets_access" {
  for_each = var.buckets

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.paas_bucket_access_key_id[each.key].arn,
      aws_secretsmanager_secret.paas_bucket_secret_access_key[each.key].arn
    ]
    effect = "Allow"
  }

  statement {
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.this.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "allow_secrets_access" {
  for_each = var.buckets

  name   = "${var.prefix}-${each.key}-s3-migration-secret-access"
  policy = data.aws_iam_policy_document.allow_secrets_access[each.key].json
}

resource "aws_iam_role_policy_attachment" "task_execution_allow_secrets_access" {
  for_each = var.buckets

  role       = aws_iam_role.task_execution[each.key].name
  policy_arn = aws_iam_policy.allow_secrets_access[each.key].arn
}

resource "aws_iam_role" "task" {
  for_each = var.buckets

  name               = "${var.prefix}-${each.key}-s3-migration-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "task_allow_bucket_access" {
  for_each = var.buckets

  role       = aws_iam_role.task[each.key].name
  policy_arn = each.value.policy_arn
}