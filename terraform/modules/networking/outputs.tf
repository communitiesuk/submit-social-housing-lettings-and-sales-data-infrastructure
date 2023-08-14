output "db_private_subnet_group_name" {
  value       = aws_db_subnet_group.private.name
  description = "The name of the private subnet group for the db"
}

output "private_subnet_cidr" {
  value       = local.private_subnet_cidr
  description = "The cidr block range for all the private subnets"
}

output "redis_private_subnet_group_name" {
  value       = aws_elasticache_subnet_group.private.name
  description = "The name of the private subnet group for redis"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The id of the main vpc"
}
