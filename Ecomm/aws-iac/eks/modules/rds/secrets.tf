resource "aws_secretsmanager_secret" "mysql_secret" {
  name        = "${var.name_prefix}-mysql-credentials"
  description = "Stores MySQL RDS credentials for ${var.name_prefix} database"
  
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "mysql_secret_value" {
  secret_id     = aws_secretsmanager_secret.mysql_secret.id
  secret_string = jsonencode({
    username     = var.db_username
    password     = var.db_password
    endpoint     = aws_db_proxy.rds_proxy.endpoint
    port         = "3306"
    database     = var.db_name
    jdbc_url     = "jdbc:mysql://${aws_db_proxy.rds_proxy.endpoint}:3306/${var.db_name}?useSSL=true&serverTimezone=UTC"
  })
  
  depends_on = [aws_db_proxy.rds_proxy]
}


