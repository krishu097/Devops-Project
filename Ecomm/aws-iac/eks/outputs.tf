output "debug_iam_role_arns" {
  description = "Debug IAM role ARNs"
  value = {
    cluster_role_arn = module.iam.cluster_iam_role_arn
    node_role_arn    = module.iam.node_iam_role_arn
    cluster_role_id  = module.iam.cluster_iam_role_arn == aws_iam_role.cluster.id ? "MATCH" : "MISMATCH"
  }
}


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
