variable "db_instance_identifier" {
  description = "Primary RDS instance identifier"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "Master username"
  type        = string
}

variable "db_password" {
  description = "Master password"
  type        = string
}

variable "rds_monitoring_role_arn" {
  description = "ARN of the IAM role for RDS Monitoring"
  type        = string
}
variable "db_engine_version" {
  description = "The version of the database engine"
  type        = string
}
variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}
variable "db_engine" {
  description = "The database engine to use"
  type        = string
}
variable "db_subnet_group_name" {
  description = "The subnet IDs for the RDS instance"
  type        = string
}
variable "db_security_group_id" {
  description = "The security group ID for the RDS instance"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "aws_region_rds_replica" {
  description = "The AWS region for RDS read replica"
  type        = string
}

variable "replica_db_subnet_group_name" {
  description = "The subnet group name for the RDS read replica"
  type        = string
}

variable "deploy_secondary" {
  description = "Deploy secondary region resources for DR"
  type        = bool
  default     = false
}