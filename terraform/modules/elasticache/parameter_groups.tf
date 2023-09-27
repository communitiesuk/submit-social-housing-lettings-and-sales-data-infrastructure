resource "aws_elasticache_parameter_group" "this" {
  name = var.prefix
  # Ensure the redis version below tallies with the engine_version defined for the redis elasticache replication group (see redis.tf)
  # Parameter group families are outlined here - https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/ParameterGroups.Redis.html
  family = "redis6.x"

  parameter {
    name  = "maxmemory-policy"
    value = "volatile-lru"
  }
}
