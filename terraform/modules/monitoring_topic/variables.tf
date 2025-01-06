variable "create_email_subscription" {
  type        = bool
  description = "Setting to true will create an email subscription for infrastructure monitoring alerts."
}

variable "create_lambda_subscription" {
  type        = bool
  description = "Setting to true will create a lambda subscription for this topic."
}

variable "email_subscription_endpoint" {
  type        = string
  description = "Email to set up subscription for - must be set if create_email_subscription is true"
  default     = null
}

variable "lambda_subscription_arn" {
  type        = string
  description = "Lambda function arn to set up subscription for - must be set if create_lambda_subscription is true"
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
