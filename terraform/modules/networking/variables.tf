variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "vpc_cidr_block" {
  type        = string
  description = "A collection of IP addresses to be allocated to VPC."
}

variable "vpc_flow_cloudwatch_log_expiration_days" {
  type        = number
  description = "Number of days to keep VPC flow logs."
}