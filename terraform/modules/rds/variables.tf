variable "allocated_storage" {
  type        = number
  description = "The allocated DB storage in gibibytes."
}

variable "create_replica_standby_db" {
  type        = bool
  description = "Flag for whether a replica standy DB should be made in case the main DB fails"
}

variable "database_port" {
  type        = number
  description = "The network port the database runs on"
}

variable "db_subnet_group_name" {
  type        = string
  description = "The name of the subnet group associated with the VPC the DB needs to be in."
}

variable "ecs_security_group_id" {
  type        = string
  description = "The id of the ecs security group for ecs ingress"
}

variable "instance_class" {
  type        = string
  description = "The instance class of the DB."
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}

variable "backup_retention_period" {
  type        = number
  description = "The number of days to retain db backups for."
}

variable "sns_topic_arn" {
  type        = string
  description = "The arn of the sns topic"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to be associated with"
}
