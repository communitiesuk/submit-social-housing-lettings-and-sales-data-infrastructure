output "redis_connection_string" {
  value       = "redis://${aws_elasticache_cluster.main.cache_nodes[0].address}:${aws_elasticache_cluster.main.cache_nodes[0].port}"
  description = "A connection string for connecting to the primary redis node, intended to be set in the environment variable REDIS_CONFIG"
  sensitive   = true
}

output "redis_security_group_id" {
  value       = aws_security_group.redis.id
  description = "The id of the redis security group"
}
