resource "aws_elasticache_replication_group" "this" {
  #checkov:skip=CKV_AWS_31:TODO CLDC-2937 potentially introduce an auth token later
  #checkov:skip=CKV_AWS_191:default encryption key is sufficient

  count = var.highly_available ? 1 : 0

  apply_immediately           = var.apply_changes_immediately
  at_rest_encryption_enabled  = true
  auto_minor_version_upgrade  = true
  automatic_failover_enabled  = true
  description                 = "Redis replication group, containing a primary node and a replica."
  engine                      = "redis"
  engine_version              = "6.2"
  maintenance_window          = "sun:23:00-mon:01:30"
  multi_az_enabled            = true
  node_type                   = var.node_type
  num_cache_clusters          = 2
  parameter_group_name        = aws_elasticache_parameter_group.this.id
  port                        = var.redis_port
  preferred_cache_cluster_azs = ["eu-west-2a", "eu-west-2b"] # The first AZ in the list is where the primary node will be created. Replicas will be created in the following AZs.
  replication_group_id        = var.prefix
  security_group_ids          = [var.redis_security_group_id]
  snapshot_retention_limit    = var.snapshot_retention_limit
  snapshot_window             = "02:30-03:30"
  subnet_group_name           = var.redis_subnet_group_name
  transit_encryption_enabled  = true
}

resource "aws_elasticache_cluster" "this" {

  count = var.highly_available ? 0 : 1

  cluster_id                 = var.prefix
  apply_immediately          = var.apply_changes_immediately
  auto_minor_version_upgrade = true
  engine                     = "redis"
  engine_version             = "6.2"
  maintenance_window         = "sun:23:00-mon:01:30"
  node_type                  = var.node_type
  num_cache_nodes            = 1
  parameter_group_name       = aws_elasticache_parameter_group.this.id
  port                       = var.redis_port
  security_group_ids         = [var.redis_security_group_id]
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = "02:30-03:30"
  subnet_group_name          = var.redis_subnet_group_name
  transit_encryption_enabled = true
}
