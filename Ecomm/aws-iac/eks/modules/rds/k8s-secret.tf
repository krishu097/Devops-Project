resource "kubernetes_secret" "rds_connection" {
  count = var.create_k8s_secret && var.deploy_secondary ? 1 : 0
  
  metadata {
    name      = "rds-connection"
    namespace = "default"
  }

  data = {
    endpoint = base64encode(aws_db_instance.primary.endpoint)
    username = base64encode(var.db_username)
    password = base64encode(var.db_password)
    database = base64encode("businessproject")
    jdbc_url = base64encode("jdbc:mysql://${aws_db_instance.primary.endpoint}/businessproject?useSSL=true&serverTimezone=UTC")
  }

  type = "Opaque"
  
  # Ensure RDS instance is ready before creating secret
  depends_on = [
    aws_db_instance.primary
  ]
}
