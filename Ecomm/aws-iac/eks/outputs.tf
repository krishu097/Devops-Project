
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "mysql_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds.mysql_endpoint
}

output "rds_proxy_endpoint" {
  description = "RDS Proxy endpoint (recommended for applications)"
  value       = module.rds.rds_proxy_endpoint
}
