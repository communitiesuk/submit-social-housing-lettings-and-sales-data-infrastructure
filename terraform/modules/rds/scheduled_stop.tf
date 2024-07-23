resource "aws_scheduler_schedule" "rds_start" {
  count = var.scheduled_stop.enabled ? 1 : 0

  name = "${var.prefix}-database-start"

  schedule_expression          = "cron(${var.scheduled_stop.timings.workday_start} ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/London"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBInstance"
    role_arn = aws_iam_role.scheduler[0].arn
    input = jsonencode({
      DbInstanceIdentifier = aws_db_instance.this.identifier
    })
  }
}

resource "aws_scheduler_schedule" "rds_stop" {
  count = var.scheduled_stop.enabled ? 1 : 0

  name = "${var.prefix}-database-stop"

  schedule_expression          = "cron(${var.scheduled_stop.timings.workday_end} ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/London"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBInstance"
    role_arn = aws_iam_role.scheduler[0].arn
    input = jsonencode({
      DbInstanceIdentifier = aws_db_instance.this.identifier
    })
  }
}

resource "aws_iam_role" "scheduler" {
  count = var.scheduled_stop.enabled ? 1 : 0

  name               = "${var.prefix}-rds-scheduler"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role[0].json
}

data "aws_iam_policy_document" "scheduler_assume_role" {
  count = var.scheduled_stop.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "allow_rds_actions" {
  count = var.scheduled_stop.enabled ? 1 : 0

  statement {
    actions = [
      "rds:Stop*",
      "rds:Start*",
      "rds:Describe*",
      "rds:Reboot*"
    ]
    resources = [aws_db_instance.this.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "allow_rds_actions" {
  count = var.scheduled_stop.enabled ? 1 : 0

  name   = "${var.prefix}-allow-rds-actions"
  policy = data.aws_iam_policy_document.allow_rds_actions[0].json
}

resource "aws_iam_role_policy_attachment" "scheduler_allow_rds_actions" {
  count = var.scheduled_stop.enabled ? 1 : 0

  role       = aws_iam_role.scheduler[0].name
  policy_arn = aws_iam_policy.allow_rds_actions[0].arn
}