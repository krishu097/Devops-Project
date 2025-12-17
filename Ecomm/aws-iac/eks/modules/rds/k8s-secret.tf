# Kubernetes secret with RDS Proxy endpoint
resource "kubernetes_secret" "rds_connection" {
  count = var.create_k8s_secret ? 1 : 0
  
  metadata {
    name      = "rds-connection"
    namespace = "default"
  }

  data = {
    endpoint  = "${aws_db_proxy.rds_proxy.endpoint}:3306"
    username  = var.db_username
    password  = var.db_password
    database  = var.db_name
    jdbc_url  = "jdbc:mysql://${aws_db_proxy.rds_proxy.endpoint}:3306/${var.db_name}?useSSL=true&serverTimezone=UTC"
  }

  type = "Opaque"
  
  depends_on = [
    aws_db_proxy.rds_proxy
  ]
}
