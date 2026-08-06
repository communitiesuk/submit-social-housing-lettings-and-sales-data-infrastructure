variable "bucket_suffix" {
  type        = string
  description = "Optional additional suffix to add to the bucket name (for uniqueness)"
  default     = ""
}

variable "cds_access_role_arns" {
  type        = list(string)
  default     = null
  description = "The arn's of the roles the CDS team will use to assume a role we define"
}

variable "ecs_task_role_arn" {
  type        = string
  description = "The arn of the app task role"
}

variable "cds_azure_user_name" {
  type        = string
  default     = null
  description = "The name of the IAM user used by the CDS team's Azure pipeline to decrypt exported data directly (without assuming the CDS role)"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}
