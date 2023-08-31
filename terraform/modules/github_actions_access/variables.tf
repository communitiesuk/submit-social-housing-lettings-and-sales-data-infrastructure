variable "application_repo" {
  type        = string
  description = "Application repository"
}

variable "ecr_arn" {
  type    = string
  description = "ARN of the ECR repository"
}

variable "meta_account_id" {
  type        = string
  description = "Account id for the meta account"
}