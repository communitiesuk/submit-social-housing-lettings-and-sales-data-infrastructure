variable "ecs_task_role_arn" {
  type        = string
  description = "The arn of the app task role"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}