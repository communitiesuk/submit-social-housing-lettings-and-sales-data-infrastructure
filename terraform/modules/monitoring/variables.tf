variable "app_service_name" {
  type        = string
  description = "The name of the app service"
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
