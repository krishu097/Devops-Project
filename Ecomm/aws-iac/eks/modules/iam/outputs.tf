output "oidc_provider_id" {
  value = aws_iam_openid_connect_provider.gmk-oidc-provider[0].id
}
output "cluster_iam_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.cluster.arn
}

output "node_iam_role_arn" {
  description = "ARN of the EKS node IAM role"
  value       = aws_iam_role.node.arn
}
