variable "allow_access_by_roles" {
  type        = list(string)
  description = "arns for the roles requiring access to the repository"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "sns_topic_arn" {
  type        = string
  description = "The arn of the sns topic"
}
