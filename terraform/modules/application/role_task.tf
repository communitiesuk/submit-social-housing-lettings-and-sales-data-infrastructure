data "aws_iam_policy_document" "task_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task" {
  name               = "${var.prefix}-task"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_database_data_access" {
  role       = aws_iam_role.task.name
  policy_arn = var.database_data_access_policy_arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_redis_access" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess"
}

#tfsec:ignore:aws-iam-no-policy-wildcards:TODO CLDC-2542 remove resource wildcard if retaining cloudwatch logging
resource "aws_iam_role_policy" "cloudwatch_logs_access" {
  #checkov:skip=CKV_AWS_290:TODO CLDC-2542 remove resource wildcard if retaining cloudwatch logging
  #checkov:skip=CKV_AWS_355:TODO CLDC-2542 remove resource wildcard if retaining cloudwatch logging
  name = "${var.prefix}-cloudwatch-logs-access"
  role = aws_iam_role.task.id

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
  })
}

data "aws_iam_policy_document" "allow_ecs_exec" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "allow_ecs_exec" {
  name   = "${var.prefix}-allow-ecs-exec"
  policy = data.aws_iam_policy_document.allow_ecs_exec.json
}

resource "aws_iam_role_policy_attachment" "task_allow_ecs_exec" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.allow_ecs_exec.arn
}

resource "aws_iam_role_policy_attachment" "task_bulk_upload_bucket_access" {
  role       = aws_iam_role.task.name
  policy_arn = var.bulk_upload_bucket_access_policy_arn
}

resource "aws_iam_role_policy_attachment" "task_export_bucket_access" {
  role       = aws_iam_role.task.name
  policy_arn = var.export_bucket_access_policy_arn
}
