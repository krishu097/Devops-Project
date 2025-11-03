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