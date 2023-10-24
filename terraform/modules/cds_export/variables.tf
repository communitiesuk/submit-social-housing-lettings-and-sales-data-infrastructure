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

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}
