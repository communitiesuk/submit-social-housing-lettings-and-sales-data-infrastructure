variable "app_service_name" {
  type        = string
  description = "The name of the app service"
}

variable "database_allocated_storage" {
  type        = string
  description = "The allocated DB storage in gibibytes."
}

variable "database_id" {
  type        = string
  description = "The id of the rds database"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ecs cluster"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "sidekiq_service_name" {
  type        = string
  description = "The name of the sidekiq service"
}
