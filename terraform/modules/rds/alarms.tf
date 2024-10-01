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
  treat_missing_data        = var.scheduled_stop.enabled ? "notBreaching" : "breaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }

  alarm_description = <<EOF
  High CPU utilization detected on RDS instance ${aws_db_instance.this.identifier}.
  Possible causes include slow-running queries or high concurrent connections.

  1. Check top SQL queries in RDS Performance Insights: [Performance Insights Dashboard](https://console.aws.amazon.com/rds/home?region=eu-west-2#performance-insights-v20206:/resourceId/${aws_db_instance.this.identifier})
  2. Investigate recent application changes or deployments.
  3. Review the CloudWatch dashboard for more metrics: [CloudWatch Dashboard](https://console.aws.amazon.com/cloudwatch/home?region=eu-west-2#dashboards)

  EOF
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
  treat_missing_data        = "breaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_anomaly" {
  alarm_name                = "${var.prefix}-rds-cpu-anomaly"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = 5
  threshold_metric_id       = "e1"
  insufficient_data_actions = []
  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = [var.sns_topic_arn]
  alarm_description         = <<EOF
  Anomaly detected in CPU utilization on RDS instance ${aws_db_instance.this.identifier}.
  This may indicate issues such as inefficient queries, unexpected traffic spikes, or resource contention.

  Recommended Actions:
  1. Check top SQL queries in RDS Performance Insights: [Performance Insights Dashboard](https://console.aws.amazon.com/rds/home?region=eu-west-2#performance-insights-v20206:/resourceId/${aws_db_instance.this.identifier})
  2. Investigate recent application changes or deployments that might be impacting performance.
  3. Review the CloudWatch dashboard for additional metrics and trends: [CloudWatch Dashboard](https://console.aws.amazon.com/cloudwatch/home?region=eu-west-2#dashboards)
  
  EOF

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "CPUUtilization (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "CPUUtilization"
      namespace   = "AWS/EC2"
      period      = 120
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        DBInstanceIdentifier = aws_db_instance.this.identifier
      }
    }
  }
}
