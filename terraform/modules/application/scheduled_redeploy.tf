#checkov:skip=CKV_AWS_297: CMK not required here and seems to cause issues
resource "aws_scheduler_schedule" "app_collection_rollover_redeploy" {
  count = var.collection_rollover_redeploy_enabled ? 1 : 0

  name = "${var.prefix}-app-collection-rollover-redeploy"

  schedule_expression          = "cron(0 0 1 4 ? *)"
  schedule_expression_timezone = "UTC"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = aws_iam_role.scheduler[0].arn

    input = jsonencode({
      Cluster            = aws_ecs_cluster.this.name,
      Service            = aws_ecs_service.app.name,
      ForceNewDeployment = true
    })
  }
}

#checkov:skip=CKV_AWS_297: CMK not required here and seems to cause issues
resource "aws_scheduler_schedule" "sidekiq_collection_rollover_redeploy" {
  count = var.collection_rollover_redeploy_enabled ? 1 : 0

  name = "${var.prefix}-sidekiq-collection-rollover-redeploy"

  schedule_expression          = "cron(0 0 1 4 ? *)"
  schedule_expression_timezone = "UTC"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = aws_iam_role.scheduler[0].arn

    input = jsonencode({
      Cluster            = aws_ecs_cluster.this.name,
      Service            = aws_ecs_service.sidekiq.name,
      ForceNewDeployment = true
    })
  }
}

resource "aws_iam_role" "scheduler" {
  count = var.collection_rollover_redeploy_enabled ? 1 : 0

  name               = "${var.prefix}-rds-scheduler"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role[0].json
}

data "aws_iam_policy_document" "scheduler_assume_role" {
  count = var.collection_rollover_redeploy_enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "allow_ecs_actions" {
  count = var.collection_rollover_redeploy_enabled ? 1 : 0

  statement {
    actions = [
      "ecs:Describe*",
      "ecs:UpdateService"
    ]
    resources = [
      aws_ecs_service.app.id,
      aws_ecs_service.sidekiq.id
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "allow_ecs_actions" {
  count = var.collection_rollover_redeploy_enabled ? 1 : 0

  name   = "${var.prefix}-allow-ecs-actions"
  policy = data.aws_iam_policy_document.allow_ecs_actions[0].json
}

resource "aws_iam_role_policy_attachment" "scheduler_allow_ecs_actions" {
  count = var.collection_rollover_redeploy_enabled ? 1 : 0

  role       = aws_iam_role.scheduler[0].name
  policy_arn = aws_iam_policy.allow_ecs_actions[0].arn
}
