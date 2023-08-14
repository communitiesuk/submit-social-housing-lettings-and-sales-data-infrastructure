output "private_subnet_group_name" {
  value       = aws_db_subnet_group.private.name
  description = "The name of the private subnet group"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The id of the main vpc"
}
