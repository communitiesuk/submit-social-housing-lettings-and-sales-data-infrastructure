output "repository_arn" {
  value       = aws_ecr_repository.core.arn
  description = "ARN for the created repository"
}
