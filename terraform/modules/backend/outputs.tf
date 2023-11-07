output "state_bucket_arn" {
  value       = module.tf_state_backend.s3_bucket_arn
  description = "Arn of the terraform state bucket created"
}