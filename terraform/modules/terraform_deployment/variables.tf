variable "assume_from_role_arns" {
  type        = list(string)
  description = "List of arns of roles that can assume the terraform deployment role"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names"
}