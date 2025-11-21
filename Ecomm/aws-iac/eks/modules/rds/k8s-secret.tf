resource "kubernetes_secret" "rds_connection" {
  count = var.create_k8s_secret ? 1 : 0
  
  metadata {
    name      = "rds-connection"
    namespace = "default"
  }

  data = {
    endpoint = aws_db_instance.primary.endpoint
    username = var.db_username
    password = var.db_password
    database = "businessproject"
    jdbc_url = "jdbc:mysql://${aws_db_instance.primary.endpoint}/businessproject?useSSL=true&serverTimezone=UTC"
  }

  type = "Opaque"
}
