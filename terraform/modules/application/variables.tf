variable "app_host" {
  type        = string
  description = "The value of the app host environment variable"
}

variable "app_task_cpu" {
  type        = number
  description = "The amount of cpu units used by the ecs app task"
}

variable "app_task_desired_count" {
  type        = number
  description = "The number of instances of the ecs app task definition desired"
}

variable "app_task_memory" {
  type        = number
  description = "The amount of memory (in MiB) used by the ecs app task"
}

variable "application_port" {
  type        = number
  description = "The network port the application runs on"
}

variable "bulk_upload_bucket_details" {
  type = object({
    aws_region  = string
    bucket_name = string
  })
  description = "Details block for bulk upload bucket"
}

variable "cloudfront_header_name" {
  type        = string
  description = "The name of the custom header used for cloudfront"
}

variable "cloudfront_header_password" {
  type        = string
  description = "The password on the custom header used for cloudfront"
}

variable "collection_resources_bucket_details" {
  type = object({
    aws_region  = string
    bucket_name = string
  })
  description = "Details block for collection resources bucket"
}

variable "collection_rollover_redeploy_enabled" {
  type        = bool
  description = "Schedules redeploy overnight on the 1st April if true"
  default     = false
}

variable "database_name" {
  type        = string
  description = "The name of the database to connect to"
}

variable "database_partial_connection_string_parameter_name" {
  type        = string
  description = "The name of the partial database connection string in the parameter store"
}

variable "ecr_repository_url" {
  type        = string
  description = "The URL of the ECR repository in the meta account"
}

variable "ecs_deployment_role_name" {
  type        = string
  description = "The name of the ecs deployment role"
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "The arn of the app task execution role"
}

variable "ecs_task_execution_role_id" {
  type        = string
  description = "The id of the app task execution role"
}

variable "ecs_task_role_arn" {
  type        = string
  description = "The arn of the app task role"
}

variable "ecs_security_group_id" {
  type        = string
  description = "The id of the ecs security group for ecs ingress"
}

variable "export_bucket_details" {
  type = object({
    aws_region  = string
    bucket_name = string
  })
  description = "Details block for export bucket"
}

variable "govuk_notify_api_key_secret_arn" {
  type        = string
  description = "The arn of the govuk notify api key secret"
}

variable "load_balancer_arn_suffix" {
  type        = string
  description = "The arn suffix of the load balancer"
}

variable "load_balancer_listener_arn" {
  type        = string
  description = "The arn of the load balancer listener"
}

variable "openai_api_key_secret_arn" {
  type        = string
  description = "The arn of the openai api key secret"
}

variable "os_data_key_secret_arn" {
  type        = string
  description = "The arn of the os data key secret"
}

variable "out_of_hours_scale_down" {
  type = object({
    enabled = bool
    timings = optional(object({
      workday_start = string
      workday_end   = string
    }))
    scale_to = optional(object({
      app     = number
      sidekiq = number
    }))
  })
  description = "Configuration for scaling down services outside of working hours. Working days are assumed to be Mon-Fri. Times should be [Minutes] [Hours] (space separated)"
  default = {
    enabled = false
  }
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

variable "rails_master_key_secret_arn" {
  type        = string
  description = "The arn of the rails master key secret"
}

variable "redis_connection_string" {
  type        = string
  description = "The value of the redis connection string"
}

variable "review_app_id" {
  type        = string
  description = "The unique identifier for the review app, used as a subdomain in the application URL."
  default     = ""
}

variable "review_app_user_password_secret_arn" {
  type        = string
  description = "Password for seeded review app users"
}

variable "sentry_dsn_secret_arn" {
  type        = string
  description = "The arn of the sentry dsn secret"
}

variable "sidekiq_task_cpu" {
  type        = number
  description = "The amount of cpu units used by the ecs sidekiq task"
}

variable "sidekiq_task_desired_count" {
  type        = number
  description = "The number of instances of the ecs sidekiq task definition desired"
}

variable "sidekiq_task_memory" {
  type        = number
  description = "The amount of memory (in MiB) used by the ecs sidekiq task"
}

variable "ad_hoc_task_cpu" {
  type        = number
  description = "The maximum amount of cpu units that can be used by the ad hoc task runner"
}

variable "ad_hoc_task_memory" {
  type        = number
  description = "The maximum amount of memory (in MiB) that can be used by the ad hoc task runner"
}

variable "sns_topic_arn" {
  type        = string
  description = "The arn of the sns topic"
}

variable "staging_performance_test_email_secret_arn" {
  type        = string
  description = "The arn of the staging performance test email secret"
  default     = null
}

variable "staging_performance_test_password_secret_arn" {
  type        = string
  description = "The arn of the staging performance test password secret"
  default     = null
}

variable "suppress_missing_data_in_alarms" {
  type        = bool
  description = "If true, cpu / memory / host count alarms treat missing data as ok - otherwise they treat it as breaching"
  default     = false
}

variable "suppress_ok_notifications" {
  type        = bool
  description = "If true, do not send notifications when alarm states change to OK"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to be associated with."
}
