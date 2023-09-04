#tfsec:ignore:aws-rds-specify-backup-retention:TODO CLDC-2661
#tfsec:ignore:aws-rds-enable-performance-insights:TODO CLDC-2660 if necessary
#tfsec:ignore:AVD-AWS-0176:iam authentication not suitable as tokens only last 15minutes, password authentication preferred
resource "aws_db_instance" "this" {
  #checkov:skip=CKV_AWS_129:cloudwatch logs TODO CLDC-2660
  #checkov:skip=CKV_AWS_118:monitoring TODO CLDC-2660
  #checkov:skip=CKV_AWS_161:iam authentication not suitable as tokens only last 15minutes, password authentication preferred
  #checkov:skip=CKV_AWS_353:performance insights TODO CLDC-2660 if necessary
  #checkov:skip=CKV_AWS_354:performance insights TODO CLDC-2660 if insights are necessary
  #checkov:skip=CKV2_AWS_30:query logging TODO CLDC-2660
  #checkov:skip=CKV2_AWS_60:copy tags to snapshots TODO CLDC-2661
  identifier                 = "${var.prefix}"
  apply_immediately          = true
  auto_minor_version_upgrade = true
  allocated_storage          = var.allocated_storage #units are GiB
  db_name                    = "data_collector"
  db_subnet_group_name       = var.db_subnet_group_name
  deletion_protection        = true # needs to be set to false and applied if you need to delete the DB
  engine                     = "postgres"
  engine_version             = "13.11"
  instance_class             = var.instance_class
  multi_az                   = true
  password                   = random_password.password.result
  port                       = var.database_port
  publicly_accessible        = false
  storage_encrypted          = true
  storage_type               = "gp2"
  username                   = "postgres"
  vpc_security_group_ids     = [aws_security_group.rds.id]

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ssm_parameter" "database_connection_string" {
  #checkov:skip=CKV_AWS_337:default encryption not using a kms cmk sufficient
  name  = "DATA_COLLECTOR_DATABASE_URL"
  type  = "SecureString"
  value = "postgresql://${aws_db_instance.main.username}:${aws_db_instance.main.password}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
}
