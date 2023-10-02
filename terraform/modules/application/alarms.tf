resource "aws_cloudwatch_metric_alarm" "app_cpu" {
  alarm_actions             = [var.sns_topic_arn]
  alarm_name                = "${var.prefix}-app-cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 3
  evaluation_periods        = 5
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  ok_actions                = [var.sns_topic_arn]
  period                    = 60
  statistic                 = "Average"
  threshold                 = 80
  insufficient_data_actions = []

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.app.name
  }
}

resource "aws_cloudwatch_metric_alarm" "app_memory" {
  alarm_actions             = [var.sns_topic_arn]
  alarm_name                = "${var.prefix}-app-memory"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 3
  evaluation_periods        = 5
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  ok_actions                = [var.sns_topic_arn]
  period                    = 60
  statistic                 = "Average"
  threshold                 = 80
  insufficient_data_actions = []

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.app.name
  }
}

resource "aws_cloudwatch_metric_alarm" "app_tasks_exited" {
  alarm_actions             = [var.sns_topic_arn]
  alarm_name                = "${var.prefix}-app-tasks-exited"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  ok_actions                = [var.sns_topic_arn]
  period                    = 8 * 60 # By causing the app to fail repeatedly (with both 2 tasks and 4 tasks running) I found that double the desired count would reliably fail in an 8 minute period.
  statistic                 = "Sum"
  threshold                 = 2 * var.app_task_desired_count
  insufficient_data_actions = []

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.app_task_exited.name
  }
}

resource "aws_cloudwatch_metric_alarm" "app_service_action_problem" {
  alarm_actions             = [var.sns_topic_arn]
  alarm_name                = "${var.prefix}-app-service-action-problem"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  ok_actions                = [var.sns_topic_arn]
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  insufficient_data_actions = []

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.app_service_action_problem.name
  }
}

resource "aws_cloudwatch_metric_alarm" "sidekiq_cpu" {
  alarm_actions             = [var.sns_topic_arn]
  alarm_name                = "${var.prefix}-sidekiq-cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 3
  evaluation_periods        = 5
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  ok_actions                = [var.sns_topic_arn]
  period                    = 60
  statistic                 = "Average"
  threshold                 = 90
  insufficient_data_actions = []

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.sidekiq.name
  }
}

resource "aws_cloudwatch_metric_alarm" "sidekiq_memory" {
  alarm_actions             = [var.sns_topic_arn]
  alarm_name                = "${var.prefix}-sidekiq-memory"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 3
  evaluation_periods        = 5
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  ok_actions                = [var.sns_topic_arn]
  period                    = 60
  statistic                 = "Average"
  threshold                 = 90
  insufficient_data_actions = []

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.sidekiq.name
  }
}

resource "aws_cloudwatch_metric_alarm" "sidekiq_tasks_exited" {
  alarm_actions             = [var.sns_topic_arn]
  alarm_name                = "${var.prefix}-sidekiq-tasks-exited"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  ok_actions                = [var.sns_topic_arn]
  period                    = 3 * 60 # By causing sidekiq to fail repeatedly (with both 1 tasks and 2 tasks running) I found that double the desired count would reliably fail in a 3 minute period.
  statistic                 = "Sum"
  threshold                 = 2 * var.sidekiq_task_desired_count
  insufficient_data_actions = []

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.sidekiq_task_exited.name
  }
}

resource "aws_cloudwatch_metric_alarm" "sidekiq_service_action_problem" {
  alarm_actions             = [var.sns_topic_arn]
  alarm_name                = "${var.prefix}-sidekiq-service-action-problem"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  ok_actions                = [var.sns_topic_arn]
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  insufficient_data_actions = []

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.sidekiq_service_action_problem.name
  }
}
