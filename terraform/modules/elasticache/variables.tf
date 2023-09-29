variable "ecs_security_group_id" {
  type        = string
  description = "The id of the ecs security group for ecs ingress"
}

variable "highly_available" {
  type        = bool
  description = "Whether or not to make redis highly available (whether to have replicas or not)."
}

variable "node_type" {
  type        = string
  description = "The type of node for the redis elasticache."
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "redis_port" {
  type        = number
  description = "The network port redis runs on"
}

variable "redis_subnet_group_name" {
  type        = string
  description = "The name of the subnet group associated with the VPC that Redis needs to be in."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to be associated with."
}
