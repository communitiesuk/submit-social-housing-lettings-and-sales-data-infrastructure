variable "additional_task_role_policy_arns" {
  type        = map(string)
  description = "The arns of further policies that need to be attached to the ecs task execution role"
}

variable "app_host" {
  type        = string
  description = "The value of the app host environment variable"
}

variable "database_connection_string_arn" {
  type        = string
  description = "The arn of the datbase connection string in parameter store"
}


variable "ecr_repository_url" {
  type        = string
  description = "The URL of the ECR repository in the meta account"
}

variable "ecs_task_cpu" {
  type        = number
  description = "The amount of cpu units used by the ecs task"
}

variable "ecs_task_desired_count" {
  type        = number
  description = "The number of instances of the ecs task defintion desired"
}

variable "ecs_task_memory" {
  type        = number
  description = "The amount of memory used by the ecs task"
}

variable "egress_to_db_security_group_id" {
  type        = string
  description = "The id of the db security group id for ecs egress"
}

variable "egress_to_redis_security_group_id" {
  type        = string
  description = "The id of the redis security group id for ecs egress"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The ids of all the private subnets"
}

variable "rails_env" {
  type        = string
  description = "The value of the rails environment variable"
}

variable "redis_connection_string" {
  type        = string
  description = "The value of the redis connection string"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to be associated with"
}