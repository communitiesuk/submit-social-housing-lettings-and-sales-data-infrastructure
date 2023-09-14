variable "cds_access_role_arn" {
  type        = string
  default     = null
  description = "The arn of the role the CDS team will use to assume a role we define"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}
