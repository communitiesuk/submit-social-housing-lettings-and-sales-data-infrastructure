output "repository_arn" {
  value       = aws_ecr_repository.this.arn
  description = "ARN for the created repository"
}