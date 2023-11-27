output "push_images_policy_arn" {
  value       = aws_iam_policy.push_images.arn
  description = "Arn of a policy allowing pushing images to this repository"
}

output "repository_arn" {
  value       = aws_ecr_repository.core.arn
  description = "ARN for the created repository"
}
