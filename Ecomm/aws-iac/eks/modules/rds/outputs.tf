output "mysql_endpoint" {
  description = "MySQL RDS instance endpoint"
  value       = aws_db_instance.primary.endpoint
}

output "mysql_port" {
  description = "MySQL RDS instance port"
  value       = aws_db_instance.primary.port
}


output "mysql_secret_arn" {
  description = "ARN of the MySQL credentials secret"
  value       = aws_secretsmanager_secret.mysql_secret.arn
}

output "mysql_replica_endpoint" {
  description = "MySQL read replica endpoint for DR"
  value       = aws_db_instance.replica.endpoint
}

output "mysql_replica_region" {
  description = "MySQL read replica region"
  value       = var.aws_region_rds_replica
}

output "rds_proxy_endpoint" {
  description = "RDS Proxy endpoint for application connections"
  value       = aws_db_proxy.rds_proxy.endpoint
}

output "rds_proxy_sg_id" {
  description = "Security group ID for RDS Proxy"
  value       = aws_security_group.rds_proxy_sg.id
}