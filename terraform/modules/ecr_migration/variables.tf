variable "allow_access_by_roles" {
  type        = list(string)
  description = "arns for the roles requiring access to the repository"
}

variable "repository_name" {
  type        = string
  description = "name for the repository"
}
