output "redis_connection_string" {
  value       = "rediss://${aws_elasticache_replication_group.this.primary_endpoint_address}:${var.redis_port}"
  description = "A connection string for connecting to the primary redis node, intended to be set in the environment variable REDIS_CONFIG"
  sensitive   = true
}
