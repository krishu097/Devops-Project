output "mysql_endpoint" {
  description = "MySQL RDS instance endpoint"
  value       = aws_db_instance.mysql.endpoint
}

output "mysql_port" {
  description = "MySQL RDS instance port"
  value       = aws_db_instance.mysql.port
}

output "mysql_database_name" {
  description = "MySQL database name"
  value       = aws_db_instance.mysql.db_name
}

output "mysql_username" {
  description = "MySQL master username"
  value       = aws_db_instance.mysql.username
  sensitive   = true
}

output "mysql_security_group_id" {
  description = "MySQL security group ID"
  value       = aws_security_group.mysql.id
}