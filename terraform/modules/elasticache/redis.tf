#tfsec:ignore:aws-elasticache-enable-backup-retention:TODO CLDC-XXXX setup a snapshot retention limit
resource "aws_elasticache_cluster" "main" {
  #checkov:skip=CKV_AWS_134:TODO CLDC-XXXX setup a snapshot retention limit
  cluster_id                 = "${var.prefix}-redis"
  auto_minor_version_upgrade = true
  apply_immediately          = true
  engine                     = "redis"
  engine_version             = "6.2"
  maintenance_window         = "sun:23:00-mon:01:30"
  node_type                  = var.node_type
  num_cache_nodes            = 1
  parameter_group_name       = aws_elasticache_parameter_group.main.id
  port                       = 6379
  security_group_ids         = [aws_security_group.redis.id]
  subnet_group_name          = var.redis_subnet_group_name
}
