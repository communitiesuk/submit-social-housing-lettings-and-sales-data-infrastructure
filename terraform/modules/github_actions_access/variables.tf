variable "application_repo" {
  type        = string
  description = "Application repository"
}

variable "ecr_arn" {
  type        = string
  description = "ARN of the ECR repository"
}

variable "infrastructure_repo" {
  type        = string
  description = "Infrastructure repository"
}

variable "meta_account_id" {
  type        = string
  description = "Account id for the meta account"
}

variable "state_bucket_arns" {
  type        = list(string)
  description = "Bucket arns of terraform state buckets to allow the infra repo to access"
}