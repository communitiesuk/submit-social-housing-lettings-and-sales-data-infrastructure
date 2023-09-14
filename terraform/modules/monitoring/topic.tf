resource "aws_sns_topic" "this" {
  #checkov:skip=CKV_AWS_26:encryption at rest is overkill for the type of data we will be sending to the topic
  name = var.prefix
}
