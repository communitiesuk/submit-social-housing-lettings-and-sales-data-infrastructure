output "state_access_policy_arn" {
  value       = aws_iam_policy.state_access.arn
  description = "Arn of policy allowing access to the state bucket and lock table"
}