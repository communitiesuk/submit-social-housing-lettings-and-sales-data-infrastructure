variable "state_bucket_name" {
  type        = string
  description = "The name of the bucket that will store the .tfstate file."
}

variable "state_log_bucket_name" {
  type        = string
  description = "The name of the bucket that will store access logs of the state bucket."
}

variable "state_lock_dynamodb_name" {
  type        = string
  description = "The name of the dynamodb table that will manage terraform state locking."
}

variable "state_replication_bucket_name" {
  type        = string
  description = "The name of the bucket that will replicate the state bucket and its files."
}
