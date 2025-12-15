# Kubernetes secret removed - create manually after cluster is ready
# kubectl create secret generic rds-connection \
#   --from-literal=endpoint="<RDS_ENDPOINT>" \
#   --from-literal=username="krish" \
#   --from-literal=password="Krish#1234" \
#   --from-literal=database="businessproject" \
#   --from-literal=jdbc_url="jdbc:mysql://<RDS_ENDPOINT>/businessproject?useSSL=true&serverTimezone=UTC"
