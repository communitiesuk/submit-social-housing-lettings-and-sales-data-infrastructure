resource "aws_sns_topic_policy" "this" {
  arn = aws_sns_topic.this.arn

  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "SNS:Publish"
    ]

    effect = "Allow"

    resources = [
      aws_sns_topic.this.arn
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "chatbot" {
  name               = "${var.prefix}-chatbot"
  assume_role_policy = data.aws_iam_policy_document.sns_assume_role_policy.json
}

data "aws_iam_policy_document" "sns_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  role       = aws_iam_role.chatbot.name
  policy_arn = aws_iam_policy.chatbot.arn
}

resource "aws_iam_policy" "chatbot" {
  name   = "chatbot-policy"
  policy = data.aws_iam_policy_document.chatbot_policy.json
}

data "aws_iam_policy_document" "chatbot_policy" {
  statement {
    actions = [
      "sns:ListTagsForResource",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:ListSMSSandboxPhoneNumbers",
      "sns:ListTopics",
      "sns:GetPlatformApplicationAttributes",
      "sns:GetSubscriptionAttributes",
      "sns:ListSubscriptions",
      "sns:CheckIfPhoneNumberIsOptedOut",
      "sns:GetDataProtectionPolicy",
      "sns:ListOriginationNumbers",
      "sns:ListPhoneNumbersOptedOut",
      "sns:ListEndpointsByPlatformApplication",
      "sns:GetEndpointAttributes",
      "sns:Publish",
      "sns:GetSMSSandboxAccountStatus",
      "sns:Subscribe",
      "sns:ConfirmSubscription",
      "sns:GetSMSAttributes",
      "sns:ListPlatformApplications"
    ]
    resources = [
      "*"
    ]
  }
}
