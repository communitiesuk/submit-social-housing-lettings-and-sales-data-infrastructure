variable "initial_create" {
  type        = bool
  description = "Set to true during an initial apply in a new environment, to avoid cloudfront referencing certificates before they've been validated manually"
  default     = false
}
