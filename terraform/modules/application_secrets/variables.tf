variable "ecs_task_execution_role_arn" {
  type        = string
  description = "The arn of the app task execution role"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}
