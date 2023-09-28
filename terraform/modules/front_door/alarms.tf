resource "aws_cloudwatch_metric_alarm" "healthy_hosts_count" {
  alarm_actions             = [var.sns_topic_arn]
  alarm_name                = "${var.prefix}-healthy-hosts-count"
  comparison_operator       = "LessThanThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = [var.sns_topic_arn]
  period                    = 60
  statistic                 = "Minimum"
  threshold                 = var.app_task_desired_count
  insufficient_data_actions = []

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
    TargetGroup  = aws_lb_target_group.this.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts_count" {
  alarm_actions             = [var.sns_topic_arn]
  alarm_name                = "${var.prefix}-unhealthy-hosts-count"
  comparison_operator       = "GreaterThanThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = [var.sns_topic_arn]
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 0
  insufficient_data_actions = []

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
    TargetGroup  = aws_lb_target_group.this.arn_suffix
  }
}
