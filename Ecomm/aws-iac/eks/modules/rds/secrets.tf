resource "aws_secretsmanager_secret" "mysql_secret" {
  name        = "${var.name_prefix}-mysql-credentials"
  description = "Stores MySQL RDS credentials for ${var.name_prefix} database"
  
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "mysql_secret_value" {
  secret_id     = aws_secretsmanager_secret.mysql_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}


