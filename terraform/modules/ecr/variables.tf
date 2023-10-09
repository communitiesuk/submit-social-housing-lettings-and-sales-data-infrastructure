variable "allow_access_by_roles" {
  type        = list(string)
  description = "arns for the roles requiring access to the repository"
}

variable "sns_topic_arn" {
  type        = string
  description = "The arn of the sns topic"
}
