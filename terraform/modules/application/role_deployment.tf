data "aws_iam_policy_document" "ecs_tasks_and_services" {
  statement {
    actions = [
      "ecs:RunTask"
    ]
    resources = [
      aws_ecs_task_definition.ad_hoc_tasks.arn_without_revision,
      aws_ecs_task_definition.app.arn_without_revision
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]
    resources = [
      aws_ecs_service.app.id,
      aws_ecs_service.sidekiq.id
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "ecs_tasks_and_services" {
  name   = "${var.prefix}-ecs-tasks-and-services"
  policy = data.aws_iam_policy_document.ecs_tasks_and_services.json
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_and_services" {
  role       = var.ecs_deployment_role_name
  policy_arn = aws_iam_policy.ecs_tasks_and_services.arn
}
