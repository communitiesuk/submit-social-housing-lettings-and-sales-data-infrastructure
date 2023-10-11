variable "app_task_desired_count" {
  type        = number
  description = "The number of instances of the ecs app task definition desired"
}

variable "application_port" {
  type        = number
  description = "The network port the application runs on"
}

variable "cloudfront_certificate_arn" {
  type        = string
  description = "The arn of the certifcate to be associated with cloudfront"
}

variable "cloudfront_domain_name" {
  type        = string
  description = "The domain name of the cloudfront distribution"
}

variable "ecs_security_group_id" {
  type        = string
  description = "The id of the ecs security group for ecs egress"
}

variable "enable_aws_shield" {
  type        = bool
  description = "Whether to enable aws shield advanced or not."
}

variable "initial_create" {
  type        = bool
  description = "Set to true for an initial create on a new environment, which will assume certs are not yet validated and so use default domain names"
}

variable "load_balancer_certificate_arn" {
  type        = string
  description = "The arn of the certifcate to be associated with the load balancer HTTPS listener"
}

variable "load_balancer_domain_name" {
  type        = string
  description = "Then domain name of the load balancer"
}

variable "load_balancer_target_group_arn_suffix" {
  type        = string
  description = "The arn suffix of the load balancer target group"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The ids of all the public subnets"
}

variable "restrict_by_ip" {
  type        = bool
  description = "True if access to cloudfront should be restricted by ip, e.g. before release or for a test environment"
}

variable "sns_topic_arn" {
  type        = string
  description = "The arn of the sns topic"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to be associated with."
}
