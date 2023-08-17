resource "aws_iam_policy" "rds-data-acess" {
  name        = "${var.prefix}-rds-data-access"
  description = "Policy that allows full access to RDS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-data:ExecuteSql",
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement",
          "rds-data:BeginTransaction",
          "rds-data:CommitTransaction",
          "rds-data:RollbackTransaction"
        ]
        Resource = aws_db_instance.main.arn
      }
    ]
  })
}
