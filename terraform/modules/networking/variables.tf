variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "vpc_cidr_block" {
  type        = string
  description = "collection of IP addresses to be allocated to VPC."
}
