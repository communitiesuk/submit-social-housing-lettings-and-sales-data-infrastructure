output "redis_connection_string" {
  value = var.highly_available ? (
    "redis://${aws_elasticache_replication_group.this[0].primary_endpoint_address}:${var.redis_port}"
    ) : (
    "redis://${aws_elasticache_cluster.this[0].cache_nodes[0].address}:${aws_elasticache_cluster.this[0].cache_nodes[0].port}"
  )
  description = "A connection string for connecting to the primary redis node, intended to be set in the environment variable REDIS_CONFIG"
  sensitive   = true
}
