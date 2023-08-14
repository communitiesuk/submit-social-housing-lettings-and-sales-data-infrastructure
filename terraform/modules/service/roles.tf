# TODO: This may not be the best way to split files, consider in CLDC-2526

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