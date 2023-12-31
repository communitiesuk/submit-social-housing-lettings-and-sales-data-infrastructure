output "db_private_subnet_group_name" {
  value       = aws_db_subnet_group.this.name
  description = "The name of the private subnet group for the db"
}

output "private_subnet_cidr" {
  value       = local.private_subnet_cidr
  description = "The cidr block range for all the private subnets"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "The ids of all the private subnets"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "The ids of all the public subnets"
}

output "redis_private_subnet_group_name" {
  value       = aws_elasticache_subnet_group.this.name
  description = "The name of the private subnet group for redis"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The id of the main vpc"
}
