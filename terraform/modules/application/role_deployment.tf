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

data "aws_iam_policy_document" "allow_deployment" {
  statement {
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:RunTask"
    ]
    resources = ["*"]
    effect    = "Allow"
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