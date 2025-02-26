locals {
  preferred_cache_cluster_azs = var.highly_available ? ["eu-west-2a", "eu-west-2b"] : ["eu-west-2a"]
}

resource "aws_elasticache_replication_group" "this" {
  #checkov:skip=CKV_AWS_31:TODO CLDC-2937 potentially introduce an auth token later
  #checkov:skip=CKV_AWS_134:redis backups not required for dev / review apps
  #checkov:skip=CKV_AWS_191:default encryption key is sufficient
  #checkov:skip=CKV2_AWS_50:redis multi-az automatic failover cannot be enabled when we want one node / no high availability
  apply_immediately           = var.apply_changes_immediately
  at_rest_encryption_enabled  = true
  auto_minor_version_upgrade  = true
  automatic_failover_enabled  = var.highly_available ? true : false
  description                 = "Redis replication group, consisting of a single node, or a primary node and a replica."
  engine                      = "redis"
  engine_version              = "6.2"
  final_snapshot_identifier   = var.skip_final_snapshot ? null : var.prefix
  maintenance_window          = "sun:23:00-mon:01:30"
  multi_az_enabled            = var.highly_available ? true : false
  node_type                   = var.node_type
  notification_topic_arn      = var.notification_topic_arn
  num_cache_clusters          = var.highly_available ? 2 : 1
  parameter_group_name        = aws_elasticache_parameter_group.this.id
  port                        = var.redis_port
  preferred_cache_cluster_azs = local.preferred_cache_cluster_azs
  replication_group_id        = var.prefix
  security_group_ids          = [var.redis_security_group_id]
  snapshot_retention_limit    = var.snapshot_retention_limit
  snapshot_window             = "02:30-03:30"
  subnet_group_name           = var.redis_subnet_group_name
  transit_encryption_enabled  = true
}
