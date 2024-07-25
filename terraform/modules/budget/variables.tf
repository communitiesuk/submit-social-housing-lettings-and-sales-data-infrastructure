variable "cost_limit" {
  type        = number
  description = "Budget for this account"
}

variable "notification_topic_arn" {
  type        = string
  description = "SNS topic for budget notifications"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names"
}