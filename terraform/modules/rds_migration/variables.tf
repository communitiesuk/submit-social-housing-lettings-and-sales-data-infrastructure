variable "cloudfoundry_service" {
  type        = string
  description = "The cloudfoundry service to use for migrating the db from gov paas"
}

variable "cloudfoundry_space" {
  type        = string
  description = "The cloudfoundry space to use for migrating the db from gov paas"
}

variable "database_connection_string_arn" {
  type        = string
  description = "The arn of the datbase connection string in parameter store"
}

variable "database_port" {
  type        = number
  description = "The network port the database runs on"
}

variable "db_migration_task_cpu" {
  type        = number
  description = "The amount of cpu units used by the ecs sidekiq task"
}

variable "db_migration_task_memory" {
  type        = number
  description = "The amount of memory used by the ecs sidekiq task"
}

variable "db_security_group_id" {
  type        = string
  description = "The id of the db security group for ecs egress"
}

variable "ecr_repository_url" {
  type        = string
  description = "The URL of the ECR repository in the meta account"
}

variable "ecs_task_ephemeral_storage" {
  type        = number
  description = "The amount of ephemeral storage for the ECS task in GiB"
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "The arn of the ecs task execution role"
}

variable "ecs_task_execution_role_name" {
  type        = string
  description = "The name of the ecs task execution role"
}

variable "ecs_task_role_arn" {
  type        = string
  description = "The arn of the ecs task role"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to be associated with"
}
