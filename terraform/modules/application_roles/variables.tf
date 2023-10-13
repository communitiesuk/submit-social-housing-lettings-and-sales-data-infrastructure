variable "bulk_upload_bucket_access_policy_arn" {
  type        = string
  description = "The arn of the policy allowing access to the bulk upload bucket"
}

variable "database_complete_connection_string_arn" {
  type        = string
  description = "The arn of the complete database connection string in the parameter store"
}

variable "database_data_access_policy_arn" {
  type        = string
  description = "The arn of the policy allowing database data access"
}

variable "export_bucket_access_policy_arn" {
  type        = string
  description = "The arn of the policy allowing access to the export bucket"
}

variable "github_actions_role_arn" {
  type        = string
  description = "The arn of the role that github actions assumes in the meta account"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "secret_arns" {
  type        = list(string)
  description = "A list of arns of all secrets whose values will need to be accessed by the ecs task execution role"
}
