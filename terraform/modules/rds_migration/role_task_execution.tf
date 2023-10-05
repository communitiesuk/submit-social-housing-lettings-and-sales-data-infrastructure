resource "aws_iam_policy" "secret_access" {
  name = "${var.prefix}-db-migration-secret-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect = "Allow"
        Resource = [
          aws_secretsmanager_secret.cloudfoundry_username.arn,
          aws_secretsmanager_secret.cloudfoundry_password.arn,
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secret_access" {
  role       = var.ecs_task_execution_role_name
  policy_arn = aws_iam_policy.secret_access.arn
}
