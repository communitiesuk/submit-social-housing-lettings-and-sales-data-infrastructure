data "aws_iam_policy_document" "deployment_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "AWS"
      identifiers = [var.github_actions_role_arn]
    }
  }
}

resource "aws_iam_role" "deployment" {
  name               = "${var.prefix}-deployment"
  assume_role_policy = data.aws_iam_policy_document.deployment_assume_role.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards: deployment action requires these permissions on all resources to function
data "aws_iam_policy_document" "allow_deployment" {
  #checkov:skip=CKV_AWS_356: deployment action requires these permissions on all resources to function
  statement {
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTasks"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = [
      aws_iam_role.task.arn,
      aws_iam_role.task_execution.arn
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "ecs:RunTask"
    ]
    resources = [
      aws_ecs_task_definition.ad_hoc_tasks.arn_without_revision,
      aws_ecs_task_definition.main.arn_without_revision
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]
    resources = [aws_ecs_service.main.id]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "allow_deployment" {
  name   = "${var.prefix}-allow-deployment"
  policy = data.aws_iam_policy_document.allow_deployment.json
}

resource "aws_iam_role_policy_attachment" "allow_deployment" {
  role       = aws_iam_role.deployment.name
  policy_arn = aws_iam_policy.allow_deployment.arn
}