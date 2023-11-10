variable "create_secrets_first" {
  type        = bool
  description = "Setting to true will avoid creating any infrastructure for which a terraform apply would fail if certain secret values are not set"
  default     = false
}
