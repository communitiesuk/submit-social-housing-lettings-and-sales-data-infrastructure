variable "api_key_secret_arn" {
  type        = string
  description = "The arn of the api key secret"
}

variable "bulk_upload_bucket_access_policy_arn" {
  type        = string
  description = "The arn of the policy allowing access to the bulk upload bucket"
}

variable "database_connection_string_arn" {
  type        = string
  description = "The arn of the datbase connection string in parameter store"
}

variable "database_data_access_policy_arn" {
  type        = string
  description = "The arn of the policy allowing database data access"
}

variable "export_bucket_access_policy_arn" {
  type        = string
  description = "The arn of the policy allowing access to the export bucket"
}

variable "govuk_notify_api_key_secret_arn" {
  type        = string
  description = "The arn of the govuk notify api key secret"
}

variable "os_data_key_secret_arn" {
  type        = string
  description = "The arn of the os data key secret"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "rails_master_key_secret_arn" {
  type        = string
  description = "The arn of the rails master key secret"
}

variable "sentry_dsn_secret_arn" {
  type        = string
  description = "The arn of the sentry dsn secret"
}
