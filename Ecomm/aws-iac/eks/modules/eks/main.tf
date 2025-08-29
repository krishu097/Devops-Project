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
    aws_cloudwatch_log_group.eks,
    module.iam.cluster_iam_role_id,
    module.iam.node_iam_role_id
  ]
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = var.tags
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
  ami_type       = lookup(each.value, "ami_type", "AL2_x86_64")
  disk_size      = lookup(each.value, "disk_size", 20)
  capacity_type  = lookup(each.value, "capacity_type", "ON_DEMAND")


  tags = merge(var.tags, {
    Name = "${each.value.name}-node-group"
  })

  depends_on = [
    aws_eks_cluster.gmk-cluster
  ]
}
