resource "aws_iam_role_policy" "parameter_access" {
  name = "${var.prefix}-parameter-access"
  role = var.ecs_task_execution_role_id

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
