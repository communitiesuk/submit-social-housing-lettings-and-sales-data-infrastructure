resource "aws_cloudwatch_metric_alarm" "app_cpu" {
  alarm_actions             = [aws_sns_topic.this.arn]
  alarm_name                = "${var.prefix}-app-cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 3
  evaluation_periods        = 5
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  ok_actions                = [aws_sns_topic.this.arn]
  period                    = 60
  statistic                 = "Average"
  threshold                 = 80
  insufficient_data_actions = []

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.app_service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "app_memory" {
  alarm_actions             = [aws_sns_topic.this.arn]
  alarm_name                = "${var.prefix}-app-memory"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 3
  evaluation_periods        = 5
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  ok_actions                = [aws_sns_topic.this.arn]
  period                    = 60
  statistic                 = "Average"
  threshold                 = 80
  insufficient_data_actions = []

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.app_service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "sidekiq_cpu" {
  alarm_actions             = [aws_sns_topic.this.arn]
  alarm_name                = "${var.prefix}-sidekiq-cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 3
  evaluation_periods        = 5
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  ok_actions                = [aws_sns_topic.this.arn]
  period                    = 60
  statistic                 = "Average"
  threshold                 = 90
  insufficient_data_actions = []

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.sidekiq_service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "sidekiq_memory" {
  alarm_actions             = [aws_sns_topic.this.arn]
  alarm_name                = "${var.prefix}-sidekiq-memory"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 3
  evaluation_periods        = 5
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  ok_actions                = [aws_sns_topic.this.arn]
  period                    = 60
  statistic                 = "Average"
  threshold                 = 90
  insufficient_data_actions = []

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.sidekiq_service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_actions             = [aws_sns_topic.this.arn]
  alarm_name                = "${var.prefix}-rds-storage"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  ok_actions                = [aws_sns_topic.this.arn]
  threshold                 = 15
  insufficient_data_actions = []

  metric_query {
    id = "freeStorageSpacePercentage"
    expression  = "freeStorageSpace/${var.database_allocated_storage}"
    period      = 60
    return_data = "true"
  }

  metric_query {
    id = "freeStorageSpace"

    metric {
      metric_name = "FreeStorageSpace"
      namespace   = "AWS/RDS"
      period      = 60
      stat        = "Minimum"

      dimensions = {
        DBInstanceIdentifier = var.database_id
      }
    }
  }

  lifecycle {
    replace_triggered_by = [var.database_id]
  }
}
