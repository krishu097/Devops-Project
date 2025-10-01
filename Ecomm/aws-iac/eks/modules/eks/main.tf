resource "aws_eks_cluster" "gmk-cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.cluster_iam_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [var.cluster_sg_id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = var.cluster_log_types

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks.arn
    }
  }

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.eks
  ]
}

encryption_config {
    resources = ["secrets"]
    provider {}
  }

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30

  tags = var.tags
}

resource "aws_eks_node_group" "gmk-node-group" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.gmk-cluster.name
  node_group_name = each.value.name
  node_role_arn   = var.node_iam_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  instance_types = each.value.instance_types
  ami_type       = each.value.ami_type
  disk_size      = each.value.disk_size
  capacity_type  = each.value.capacity_type

  tags = merge(var.tags, {
    Name = "${each.value.name}-node-group"
  })

  depends_on = [
    aws_eks_cluster.gmk-cluster
  ]
}
