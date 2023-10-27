variable "buckets" {
  type = map(object(
    {
      source      = string,
      destination = string,
      policy_arn  = string
  }))
  description = "For each bucket to migrate, s3 urls for the source and destination and the arn for a policy allowing access to the destination bucket"
}

variable "ecr_repository_url" {
  type        = string
  description = "The URL of the ECR repository in the meta account"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to be associated with"
}