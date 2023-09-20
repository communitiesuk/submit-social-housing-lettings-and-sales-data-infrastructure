# resource "awscc_chatbot_slack_channel_configuration" "this" {
#   configuration_name = var.prefix
#   iam_role_arn       = aws_iam_role.chatbot.arn
#   # slack_channel_id   = var.slack_channel_id
#   slack_channel_id   = "C05RYE5CYCX"
#   # slack_workspace_id = var.slack_workspace_id
#   slack_workspace_id = "T02MTJKG5"
#   sns_topic_arns     = [aws_sns_topic.this.arn]
# }
