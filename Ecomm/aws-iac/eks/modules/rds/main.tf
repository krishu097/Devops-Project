# Primary MySQL RDS instance
resource "aws_db_instance" "primary" {
  identifier              = var.db_instance_identifier
  allocated_storage       = 20
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  username = jsondecode(aws_secretsmanager_secret_version.mysql_secret_value.secret_string)["username"]
  password = jsondecode(aws_secretsmanager_secret_version.mysql_secret_value.secret_string)["password"]
  db_name                 = var.db_name
  storage_encrypted       = true
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = var.db_security_group_id
  monitoring_role_arn     = var.rds_monitoring_role_arn
  monitoring_interval     = 30

  backup_retention_period = 7
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
  multi_az                = false

depends_on = [
    aws_secretsmanager_secret_version.mysql_secret_value
  ]

}

# Cross-region Read Replica
resource "aws_db_instance" "replica" {
  provider                = aws.replica
  identifier              = "${var.db_instance_identifier}-replica"

  replicate_source_db     = aws_db_instance.primary.arn

  instance_class          = var.db_instance_class

  storage_encrypted       = true
  kms_key_id              = aws_kms_key.rds_replica_key.arn
  db_subnet_group_name    = var.replica_db_subnet_group_name

  publicly_accessible     = false
  skip_final_snapshot     = true
  
}

resource "aws_kms_key" "rds_replica_key" {
  provider = aws.replica
  description = "KMS key for RDS cross-region replica encryption"
  deletion_window_in_days = 7
  enable_key_rotation = true
}