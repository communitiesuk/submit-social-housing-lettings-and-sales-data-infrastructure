variable "application_port" {
  type        = number
  description = "The network port the application runs on"
}

variable "database_port" {
  type        = number
  description = "The network port the database runs on"
}

variable "db_security_group_id" {
  type        = string
  description = "The id of the db security group for ecs egress"
}

variable "load_balancer_security_group_id" {
  type        = string
  description = "The id of the load balancer security group for ecs egress"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "redis_port" {
  type        = number
  description = "The network port redis runs on"
}

variable "redis_security_group_id" {
  type        = string
  description = "The id of the redis security group for ecs egress"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to be associated with"
}
