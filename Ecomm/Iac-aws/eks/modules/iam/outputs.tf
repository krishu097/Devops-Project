output "cluster_iam_role_id" {
  value = aws_iam_role.cluster.id
}

output "node_iam_role_id" {
  value = aws_iam_role.node.id
}

output "oidc_provider_id" {
  value = aws_iam_openid_connect_provider.gmk-oidc-provider[0].id
}
