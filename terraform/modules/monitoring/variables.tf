variable "create_secrets_first" {
  type        = bool
  description = "Setting to true will avoid creating the email subscription (and any other infra) for which a terraform apply would fail if the value of certain secrets were not set."
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "service_identifier_publishing_to_sns" {
  type        = string
  description = "The identifier of the service that will be publishing to SNS"
}
