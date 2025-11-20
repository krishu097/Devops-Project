resource "kubernetes_secret" "rds_connection" {
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
}