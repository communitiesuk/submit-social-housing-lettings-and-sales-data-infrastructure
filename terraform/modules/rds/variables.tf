variable "allocated_storage" {
  type        = number
  description = "The allocated DB storage in gibibytes."
}

variable "db_subnet_group_name" {
  type        = string
  description = "The name of the subnet group associated with the VPC the DB needs to be in."
}

variable "instance_class" {
  type        = string
  description = "The instance class of the DB."
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "ingress_source_security_group_ids" {
  type        = list(string)
  description = "The security group ids (sources) the rds security group will allow ingress from"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to be associated with"
}
