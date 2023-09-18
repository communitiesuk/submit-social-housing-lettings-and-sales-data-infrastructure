resource "aws_cloudwatch_metric_alarm" "app_cpu" {
  alarm_actions             = [aws_sns_topic.this.arn]
  alarm_name                = "${var.prefix}-app-cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  ok_actions                = [aws_sns_topic.this.arn]
  period                    = 30
  statistic                 = "Average"
  threshold                 = 0
  insufficient_data_actions = []

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.app_service_name
  }
}
