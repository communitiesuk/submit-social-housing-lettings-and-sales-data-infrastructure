#tfsec:ignore:aws-elasticache-enable-backup-retention:TODO CLDC-2679 setup a snapshot retention limit
resource "aws_elasticache_replication_group" "this" {
  #checkov:skip=CKV_AWS_134:TODO CLDC-2679 setup a snapshot retention limit
  #TODO CLDC-2682 setup redis logging
  apply_immediately           = true
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
  preferred_cache_cluster_azs = ["eu-west-2", "eu-west-1"] # The first AZ in the list is where the primary node will be created. Replicas will be created in the following AZs.
  replication_group_id        = var.prefix
  security_group_ids          = [aws_security_group.this.id]
  subnet_group_name           = var.redis_subnet_group_name
}
