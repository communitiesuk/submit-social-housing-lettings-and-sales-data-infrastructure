output "state_details" {
  value = {
    bucket_arn     = module.tf_state_backend.s3_bucket_arn
    lock_table_arn = module.tf_state_backend.dynamodb_table_arn
  }
  description = "Details of the terraform state bucket and associated lock table"
}