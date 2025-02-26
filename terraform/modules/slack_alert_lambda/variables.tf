variable "dead_letter_monitoring_email" {
  type        = string
  description = "Email to recieve alerts for messages sent to the dead letter queue"
}

variable "environment" {
  type        = string
  description = "Environment identifier to use in slack alert"
}

variable "monitoring_topics" {
  type        = list(string)
  description = "A list of arns of all sns topics to allow to trigger the alert function"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "slack_webhook_url" {
  type        = string
  description = "Slack webhook url for sending alerts"
}