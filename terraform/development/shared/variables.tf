variable "create_secrets_first" {
  type        = bool
  description = "Setting to true will avoid creating any infrastructure for which a terraform apply would fail if certain secret values are not set"
  default     = false
}

variable "initial_create" {
  type        = bool
  description = "Set to true during an initial apply in a new environment, to avoid cloudfront referencing certificates before they've been validated manually"
  default     = false
}
