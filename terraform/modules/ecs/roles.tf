resource "aws_iam_role" "task" {
  name               = "${var.prefix}-task"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_additional_policies" {
  for_each   = var.additional_task_role_policy_arns
  role       = aws_iam_role.task.name
  policy_arn = each.value
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
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:PutRetentionPolicy"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
  })
}

resource "aws_iam_role" "task_execution" {
  name               = "${var.prefix}-task-execution"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
}

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

resource "aws_iam_role_policy_attachment" "task_execution_managed_policy" {
  role = aws_iam_role.task_execution.name
  # This is an aws managed policy for ecs task execution roles
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "parameter_access" {
  for_each = var.ecs_parameters

  name = "${var.prefix}-parameter-access-${each.key}"
  role = aws_iam_role.task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameters"
        ]
        Effect   = "Allow"
        Resource = each.value
      }
    ]
  })
}
