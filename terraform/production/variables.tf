variable "parameters" {
  description = "A map of parameter values. Keys should be a subset of the ones passed to 'parameters' module."
  type        = map(string)
  sensitive   = true
}
