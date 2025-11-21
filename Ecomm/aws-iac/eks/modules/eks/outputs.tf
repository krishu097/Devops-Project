output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = length(aws_eks_cluster.gmk-cluster) > 0 ? aws_eks_cluster.gmk-cluster[0].identity[0].oidc[0].issuer : null
}

output "cluster_id" {
  description = "EKS cluster ID"
  value       = length(aws_eks_cluster.gmk-cluster) > 0 ? aws_eks_cluster.gmk-cluster[0].id : null
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = length(aws_eks_cluster.gmk-cluster) > 0 ? aws_eks_cluster.gmk-cluster[0].arn : null
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = length(aws_eks_cluster.gmk-cluster) > 0 ? aws_eks_cluster.gmk-cluster[0].endpoint : null
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = length(aws_eks_cluster.gmk-cluster) > 0 ? aws_eks_cluster.gmk-cluster[0].certificate_authority[0].data : null
}
