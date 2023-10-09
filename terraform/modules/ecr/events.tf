resource "aws_cloudwatch_event_rule" "ecr_image_scan_results" {
  name        = "${aws_ecr_repository.core.name}-ecr-image-scan-results"
  description = "ECR image scan results that identify MEDIUM and/or HIGH and/or CRITICAL severity vulnerabilities"
  event_pattern = jsonencode(
    {
      "source" : ["aws.ecr"],
      "detail-type" : ["ECR Image Scan"],
      "resources" : [aws_ecr_repository.core.arn],
      "detail" : {
        "finding-severity-counts" : {
          "$or" : [
            {
              "CRITICAL" : [{
                "numeric" : [">", 0]
              }]
            },
            {
              "HIGH" : [{
                "numeric" : [">", 0]
              }]
            },
            {
              "MEDIUM" : [{
                "numeric" : [">", 0]
              }]
            }
          ]
        },
        "repository-name" : [aws_ecr_repository.core.name]
      }
    }
  )
}

resource "aws_cloudwatch_event_target" "ecr_scan_event_target" {
  arn  = var.sns_topic_arn
  rule = aws_cloudwatch_event_rule.ecr_image_scan_results.name
}
