variable "allocated_storage" {
  type        = number
  description = "The allocated DB storage in gibibytes."
}

variable "apply_changes_immediately" {
  type        = bool
  description = "Whether to apply changes to the db immediately or to wait for the next maintenance window."
}

variable "backup_retention_period" {
  type        = number
  description = "The number of days to retain db backups for. If 0 then the database will not be backed up"
}

variable "backup_window" {
  type        = string
  description = "Backup window for the db. If scheduled stop is enabled this should be within the db on times"
  default     = "23:09-23:39"
}

variable "create_replica" {
  type        = bool
  description = "If true, creates a replica db"
  default     = false
}

variable "database_port" {
  type        = number
  description = "The network port the database runs on"
}

variable "db_subnet_group_name" {
  type        = string
  description = "The name of the subnet group associated with the VPC the DB needs to be in."
}

variable "enable_primary_deletion_protection" {
  type        = bool
  description = "Whether the primary database should have deletion protection enabled"
}

variable "enable_replica_deletion_protection" {
  type        = bool
  description = "Whether the replica database (if create_replica is true) should have deletion protection enabled"
  default     = true
}

variable "ecs_security_group_id" {
  type        = string
  description = "The id of the ecs security group for ecs ingress"
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "The arn of the app task execution role"
}

variable "instance_class" {
  type        = string
  description = "The instance class of the DB."
}

variable "maintenance_window" {
  type        = string
  description = "Maintenance window for the db. If scheduled stop is enabled this sholud be during the db on times"
  default     = "Mon:02:33-Mon:03:03"
}

variable "multi_az" {
  type        = bool
  description = "Whether the database should be multi-az"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "scheduled_stop" {
  type = object({
    enabled = bool
    timings = optional(object({
      workday_start = string
      workday_end   = string
    }))
  })
  description = "Settings for automatically stopping the database outside of working hours. Currently assumes that no replica is being created."
  default = {
    enabled = false
  }
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Whether to create a final snapshot before the database instance is deleted"
}

variable "sns_topic_arn" {
  type        = string
  description = "The arn of the sns topic"
}

variable "use_customer_managed_key_for_performance_insights" {
  type        = bool
  description = "Whether to use a customer managed kms key for performance insights encryption (if false uses aws default)"
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to be associated with"
}
