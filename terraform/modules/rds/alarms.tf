resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_actions             = [var.sns_topic_arn]
  alarm_name                = "${var.prefix}-rds-cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 3
  evaluation_periods        = 5
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  ok_actions                = [var.sns_topic_arn]
  period                    = 60
  statistic                 = "Average"
  threshold                 = 90
  insufficient_data_actions = []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_actions             = [var.sns_topic_arn]
  alarm_name                = "${var.prefix}-rds-storage"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  metric_name               = "FreeStorageSpace"
  namespace                 = "AWS/RDS"
  ok_actions                = [var.sns_topic_arn]
  period                    = 300
  statistic                 = "Minimum"
  threshold                 = aws_db_instance.this.allocated_storage * 0.15
  insufficient_data_actions = []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }
}
