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
  description = "Then domain name of the cloudfront distribution"
}

variable "ecs_security_group_id" {
  type        = string
  description = "The id of the ecs security group for ecs egress"
}

variable "load_balancer_certificate_arn" {
  type        = string
  description = "The arn of the certifcate to be associated with the load balancer HTTPS listener"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The ids of all the public subnets"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to be associated with."
}
