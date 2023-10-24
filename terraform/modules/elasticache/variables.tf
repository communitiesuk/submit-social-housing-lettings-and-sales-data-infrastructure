variable "apply_changes_immediately" {
  type        = bool
  description = "Whether to apply changes to redis immediately or to wait for the next maintenance window."
}

variable "redis_security_group_id" {
  type        = string
  description = "The id of the redis security group"
}

variable "highly_available" {
  type        = bool
  description = "Whether or not to make redis highly available (whether to have replicas or not)."
}

variable "node_type" {
  type        = string
  description = "The type of node for the redis elasticache."
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "redis_port" {
  type        = number
  description = "The network port redis runs on"
}

variable "redis_subnet_group_name" {
  type        = string
  description = "The name of the subnet group associated with the VPC that Redis needs to be in."
}

variable "snapshot_retention_limit" {
  type        = number
  description = "The number of days the automatic cache cluster snapshots are retained before being deleted. If 0 then backups are turned off"
}
