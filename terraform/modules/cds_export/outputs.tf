output "details" {
  value       = { aws_region : aws_s3_bucket.this.region, bucket_name : aws_s3_bucket.this.id }
  description = "Details block for this bucket for the application to use to connect"
}

output "read_write_policy_arn" {
  value       = aws_iam_policy.read_write.arn
  description = "Arn for policy allowing read/write access to objects in this bucket"
}