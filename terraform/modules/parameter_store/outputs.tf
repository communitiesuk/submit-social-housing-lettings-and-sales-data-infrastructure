output "parameter_arns" {
  value       = { for index, parameter in aws_ssm_parameter.this : parameter.name => parameter.arn }
  description = "An output of the arn of each parameter in the store"
}
