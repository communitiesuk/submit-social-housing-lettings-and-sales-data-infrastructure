data "aws_iam_policy_document" "task_execution_assume_role" {
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
  name               = "${var.prefix}-task-execution"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role.json
}

resource "aws_iam_role_policy_attachment" "task_execution_managed_policy" {
  role = aws_iam_role.task_execution.name
  # This is an aws managed policy for ecs task execution roles
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "parameter_access" {
  name = "${var.prefix}-parameter-access"
  role = aws_iam_role.task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameters"
        ]
        Effect   = "Allow"
        Resource = [aws_ssm_parameter.complete_database_connection_string.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy" "secret_access" {
  name = "${var.prefix}-secret-access"
  role = aws_iam_role.task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect = "Allow"
        Resource = [
          var.api_key_secret_arn,
          var.govuk_notify_api_key_secret_arn,
          var.os_data_key_secret_arn,
          var.rails_master_key_secret_arn,
          var.sentry_dsn_secret_arn
        ]
      }
    ]
  })
}