variable "initial_create" {
  type        = bool
  description = "Set to true for the initial creation of this environment to avoid referencing secret values that need to be set after they are first created"
  default     = false
}
