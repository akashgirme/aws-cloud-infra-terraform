# RDS Instance
resource "aws_db_instance" "rds_instance" {
  engine         = "postgres"
  engine_version = var.rds_engine_version
  instance_class = var.instance_class
  identifier     = "${var.environment}-skillstreet-database"
  db_name        = var.db_name
  username       = var.db_username
  password       = var.db_password
  port           = 5432

  multi_az = var.isMultiAZ

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted

  auto_minor_version_upgrade = true

  parameter_group_name = aws_db_parameter_group.parameter_group.name

  backup_retention_period               = 30
  performance_insights_enabled          = true
  performance_insights_retention_period = var.performance_insights_retention_period

  skip_final_snapshot = true
  # Uncomment all at time of final infrastructure Provision
  # final_snapshot_identifier = "snapshot-before-database-is-deleted"   // Set skip_final_snapshot = false
  # delete_automated_backups = true
  # deletion_protection = true
  # manage_master_user_password = true  // Remove Password before enabling it. Can't set when Password is enabled
  # deletion_protection = true

  vpc_security_group_ids = [var.security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_private_subnets_group.name
  publicly_accessible    = false

  depends_on = [var.vpc, var.security_group, aws_db_subnet_group.rds_private_subnets_group]

  tags = {
    Name = "${var.environment}-postgres-database"
  }
}

# DB Parameter Group
resource "aws_db_parameter_group" "parameter_group" {
  name   = "${var.environment}-postgres-rds-param-group"
  family = var.db_parameter_group_family

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  tags = {
    Name = "${var.environment}-postgres-rds-param-group"
  }
}


# Private Subnets Group
resource "aws_db_subnet_group" "rds_private_subnets_group" {
  name       = "${var.environment}-rds-private-subnet-group"
  subnet_ids = var.private_subnets.*.id

  depends_on = [var.private_subnets]

  tags = {
    Name = "${var.environment}-rds-private-subnet-group"
  }
}
