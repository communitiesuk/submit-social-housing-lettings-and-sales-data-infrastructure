resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx_error_rate" {
  provider = aws.us-east-1

  alarm_actions             = [var.alarm_topic_arn]
  alarm_name                = "${var.prefix}-cloudfront-5xx-error-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  metric_name               = "5xxErrorRate"
  namespace                 = "AWS/CloudFront"
  ok_actions                = [var.alarm_topic_arn]
  period                    = 60
  statistic                 = "Average"
  threshold                 = 5
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.this.id
    Region         = "Global"
  }
}
