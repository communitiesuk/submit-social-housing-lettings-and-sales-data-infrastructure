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
  description = "Whether the replica database should have deletion protection enabled"
}

variable "ecs_security_group_id" {
  type        = string
  description = "The id of the ecs security group for ecs ingress"
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "The arn of the app task execution role"
}

variable "highly_available" {
  type        = bool
  description = "Whether or not to make the db highly available (whether to have replicas or not)."
}

variable "instance_class" {
  type        = string
  description = "The instance class of the DB."
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Whether to create a final snapshot before the database instance is deleted"
}

variable "sns_topic_arn" {
  type        = string
  description = "The arn of the sns topic"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to be associated with"
}
