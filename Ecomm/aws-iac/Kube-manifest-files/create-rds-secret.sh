#!/bin/bash

# Script to create RDS connection secret after EKS cluster is ready
# Run this after terraform apply completes successfully

set -e

echo "Creating RDS connection secret in Kubernetes..."

# Get RDS endpoint from terraform output
RDS_ENDPOINT=$(terraform output -raw mysql_endpoint)
DB_USERNAME="krish"
DB_PASSWORD="Krish#1234"

# Create the secret
kubectl create secret generic rds-connection \
  --from-literal=endpoint="$RDS_ENDPOINT" \
  --from-literal=username="$DB_USERNAME" \
  --from-literal=password="$DB_PASSWORD" \
  --from-literal=database="businessproject" \
  --from-literal=jdbc_url="jdbc:mysql://$RDS_ENDPOINT/businessproject?useSSL=true&serverTimezone=UTC" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ RDS connection secret created successfully!"
echo "Secret name: rds-connection"
echo "Namespace: default"