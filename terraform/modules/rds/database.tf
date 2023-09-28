#tfsec:ignore:aws-rds-enable-performance-insights:TODO CLDC-2660 if necessary
#tfsec:ignore:AVD-AWS-0176:iam authentication not suitable as tokens only last 15minutes, password authentication preferred
resource "aws_db_instance" "this" {
  #checkov:skip=CKV_AWS_129:cloudwatch logs TODO CLDC-2660
  #checkov:skip=CKV_AWS_118:monitoring TODO CLDC-2660
  #checkov:skip=CKV_AWS_161:iam authentication not suitable as tokens only last 15minutes, password authentication preferred
  #checkov:skip=CKV_AWS_353:performance insights TODO CLDC-2660 if necessary
  #checkov:skip=CKV_AWS_354:performance insights TODO CLDC-2660 if insights are necessary
  #checkov:skip=CKV2_AWS_30:query logging TODO CLDC-2660
  identifier                 = var.prefix
  apply_immediately          = true
  auto_minor_version_upgrade = true
  allocated_storage          = var.allocated_storage #units are GiB
  backup_retention_period    = var.backup_retention_period
  backup_window              = "23:09-23:39"
  copy_tags_to_snapshot      = true
  db_name                    = "data_collector"
  db_subnet_group_name       = var.db_subnet_group_name
  delete_automated_backups   = false
  deletion_protection        = true # needs to be set to false and applied if you need to delete the DB
  engine                     = "postgres"
  engine_version             = "13.11"
  final_snapshot_identifier  = var.prefix
  instance_class             = var.instance_class
  maintenance_window         = "Mon:02:33-Mon:03:03"
  multi_az                   = true
  password                   = random_password.this.result
  port                       = var.database_port
  publicly_accessible        = false
  skip_final_snapshot        = false
  storage_encrypted          = true
  storage_type               = "gp2"
  username                   = "postgres"
  vpc_security_group_ids     = [aws_security_group.this.id]

  lifecycle {
    prevent_destroy = true
  }
}

#tfsec:ignore:aws-rds-enable-performance-insights:TODO CLDC-2660 if necessary
#tfsec:ignore:AVD-AWS-0176:iam authentication not suitable as tokens only last 15minutes, password authentication preferred
resource "aws_db_instance" "replica" {
  #checkov:skip=CKV_AWS_129:cloudwatch logs TODO CLDC-2660
  #checkov:skip=CKV_AWS_118:monitoring TODO CLDC-2660
  #checkov:skip=CKV_AWS_161:iam authentication not suitable as tokens only last 15minutes, password authentication preferred
  #checkov:skip=CKV_AWS_353:performance insights TODO CLDC-2660 if necessary
  #checkov:skip=CKV_AWS_354:performance insights TODO CLDC-2660 if insights are necessary
  #checkov:skip=CKV2_AWS_30:query logging TODO CLDC-2660
  count               = var.create_replica_standby_db ? 1 : 0
  identifier          = "${var.prefix}-replica"
  replicate_source_db = aws_db_instance.this.arn

  apply_immediately          = aws_db_instance.this.apply_immediately
  auto_minor_version_upgrade = aws_db_instance.this.auto_minor_version_upgrade
  copy_tags_to_snapshot      = aws_db_instance.this.copy_tags_to_snapshot
  db_subnet_group_name       = aws_db_instance.this.db_subnet_group_name
  delete_automated_backups   = aws_db_instance.this.delete_automated_backups
  deletion_protection        = true # needs to be set to false and applied if you need to delete the DB
  final_snapshot_identifier  = aws_db_instance.this.final_snapshot_identifier
  instance_class             = aws_db_instance.this.instance_class
  maintenance_window         = aws_db_instance.this.maintenance_window
  multi_az                   = aws_db_instance.this.multi_az
  port                       = aws_db_instance.this.port
  publicly_accessible        = aws_db_instance.this.publicly_accessible
  skip_final_snapshot        = aws_db_instance.this.skip_final_snapshot
  storage_encrypted          = aws_db_instance.this.storage_encrypted
  storage_type               = aws_db_instance.this.storage_type
  vpc_security_group_ids     = aws_db_instance.this.vpc_security_group_ids

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ssm_parameter" "database_connection_string" {
  #checkov:skip=CKV_AWS_337:default encryption not using a kms cmk sufficient
  name  = "DATA_COLLECTOR_DATABASE_URL"
  type  = "SecureString"
  value = "postgresql://${aws_db_instance.this.username}:${aws_db_instance.this.password}@${aws_db_instance.this.endpoint}/${aws_db_instance.this.db_name}"
}
