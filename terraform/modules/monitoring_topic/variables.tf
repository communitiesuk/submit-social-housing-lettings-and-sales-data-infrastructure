variable "create_email_subscription" {
  type        = bool
  description = "Setting to true will create an email subscription for infrastructure monitoring alerts."
}

variable "create_lambda_slack_subscription" {
  type        = bool
  description = "Setting to true will create a lambda to send slack alerts for messages to this topic."
  default     = false
}

variable "email_subscription_endpoint" {
  type        = string
  description = "Email to set up subscription for - must be set if create_email_subscription is true"
  default     = null
}

variable "environment" {
  type        = string
  description = "Environment identifier to use in slack alert. Expected 'Production', 'Staging', or 'Review'."
  default     = null
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names"
}

variable "service_identifiers_publishing_to_sns" {
  type        = list(string)
  description = "Identifiers of the services that will be publishing to SNS"
}

variable "slack_webhook_url" {
  type        = string
  description = "Slack webhook url for sending alerts. Must be set if create_lambda_slack_subscription is true."
  default     = ""
}
