# Primary MySQL RDS instance
data "aws_secretsmanager_secret_version" "mysql_secret" {
  secret_id = aws_secretsmanager_secret.mysql_secret.id
}

resource "aws_db_instance" "primary" {
  identifier              = var.db_instance_identifier
  allocated_storage       = 20
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  username = jsondecode(data.aws_secretsmanager_secret_version.mysql_secret.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.mysql_secret.secret_string)["password"]
  db_name                 = var.db_name
  storage_encrypted       = true
  db_subnet_group_name    = var.subnet_ids
  vpc_security_group_ids  = var.db_security_group_id
  monitoring_role_arn     = var.rds_monitoring_role_arn
  monitoring_interval     = 30

  backup_retention_period = 7
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
  multi_az                = false
}

# Cross-region Read Replica
resource "aws_db_instance" "replica" {
  provider                = aws
  region                  = var.aws_region_rds_replica
  identifier              = "${var.db_instance_identifier}-replica"

  replicate_source_db     = aws_db_instance.primary.arn

  instance_class          = var.db_instance_class

  storage_encrypted       = true

  publicly_accessible     = false
  skip_final_snapshot     = true
}

