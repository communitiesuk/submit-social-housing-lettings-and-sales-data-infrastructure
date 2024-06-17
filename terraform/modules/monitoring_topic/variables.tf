variable "create_email_subscription" {
  type        = bool
  description = "Setting to true will create an email subscription for infrastructure monitoring alerts."
}

variable "email_subscription_endpoint" {
  type        = string
  description = "Email to set up subscription for - must be set if create_email_subscription is true"
  default     = null
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names"
}

variable "service_identifier_publishing_to_sns" {
  type        = string
  description = "The identifier of the service that will be publishing to SNS"
}