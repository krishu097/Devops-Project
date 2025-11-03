output "oidc_provider_id" {
  value = aws_iam_openid_connect_provider.eks.id
}
output "cluster_iam_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.cluster.arn
}

output "node_iam_role_arn" {
  description = "ARN of the EKS node IAM role"
  value       = aws_iam_role.node.arn
}

output "eks_access_ecr_role_arn" {
  description = "ARN of the IAM role for EKS to access ECR"
  value       = aws_iam_role.eks_ecr_access_role.arn
}

output "ebs_csi_driver_role_arn" {
  description = "ARN of the IAM role for EBS CSI Driver"
  value       = aws_iam_role.ebs_csi_driver.arn
}

output "rds_monitoring_role_arn" {
  description = "ARN of the IAM role for RDS Monitoring"
  value       = aws_iam_role.rds_monitoring.arn
}