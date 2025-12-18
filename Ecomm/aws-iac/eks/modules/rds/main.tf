terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      configuration_aliases = [aws.replica]
    }
  }
}

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
  vpc_security_group_ids  = [aws_security_group.rds_proxy_sg.id]
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

# Cross-region Read Replica (always created for DR)
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
  
  tags = {
    Name = "${var.db_instance_identifier}-replica"
    Purpose = "DR-ReadReplica"
  }
}

resource "aws_kms_key" "rds_replica_key" {
  provider    = aws.replica
  description = "KMS key for RDS cross-region replica encryption"
  deletion_window_in_days = 7
  enable_key_rotation = true
  
  tags = {
    Name = "rds-replica-key"
    Purpose = "DR-Encryption"
  }
}

# Security group for RDS Proxy
resource "aws_security_group" "rds_proxy_sg" {
  name        = "${var.name_prefix}-rds-proxy-sg"
  description = "Security group for RDS Proxy"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_nodes_security_group_id]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-rds-proxy-sg"
  }
}

# RDS Proxy for connection pooling and management
resource "aws_db_proxy" "rds_proxy" {
  name                   = "ecomm-uat-rds-proxy"
  engine_family         = "MYSQL"
  
  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.mysql_secret.arn
  }
  
  role_arn               = aws_iam_role.rds_proxy_role.arn
  vpc_subnet_ids         = data.aws_subnets.db_subnets.ids
  vpc_security_group_ids = [aws_security_group.rds_proxy_sg.id]
  require_tls            = false
  
  tags = {
    Name = "${var.name_prefix}-rds-proxy"
    Purpose = "Connection-Pooling"
  }
}

# RDS Proxy Target
resource "aws_db_proxy_default_target_group" "rds_proxy_target" {
  db_proxy_name = aws_db_proxy.rds_proxy.name
  
  connection_pool_config {
    max_connections_percent      = 100
    max_idle_connections_percent = 50
    connection_borrow_timeout    = 120
  }
}

resource "aws_db_proxy_target" "rds_proxy_target" {
  db_instance_identifier = aws_db_instance.primary.identifier
  db_proxy_name          = aws_db_proxy.rds_proxy.name
  target_group_name      = aws_db_proxy_default_target_group.rds_proxy_target.name
}

# Data source to get subnet IDs from subnet group
data "aws_subnets" "db_subnets" {
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

# IAM role for RDS Proxy
resource "aws_iam_role" "rds_proxy_role" {
  name = "ecomm-uat-rds-proxy-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for RDS Proxy to access Secrets Manager
resource "aws_iam_role_policy" "rds_proxy_policy" {
  name = "ecomm-uat-rds-proxy-policy"
  role = aws_iam_role.rds_proxy_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.mysql_secret.arn
      }
    ]
  })
}