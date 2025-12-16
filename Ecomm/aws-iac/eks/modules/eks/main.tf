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

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.eks
  ]
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.gmk-cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs-addon-version
  service_account_role_arn = var.ebs_csi_driver_role

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags

  depends_on = [
    aws_eks_node_group.gmk-node-group
  ]
}


resource "kubernetes_namespace" "amazon_cloudwatch" {
  metadata {
    name = "amazon-cloudwatch"
  }

}

resource "kubernetes_service_account" "cloudwatch-agent" {
  metadata {
    name      = "cloudwatch-agent"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = var.cloudwatch_agent_role
    }
  }
}

resource "kubernetes_service_account" "fluent_bit" {
  metadata {
    name      = "fluent-bit"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = var.cloudwatch_agent_role
    }
  }
}



resource "aws_eks_addon" "cloudwatch_observability" {
  # Deploy in both primary and secondary regions for monitoring
  count = 1
  
  cluster_name  = aws_eks_cluster.gmk-cluster.name
  addon_name    = "amazon-cloudwatch-observability"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }

  depends_on = [
    kubernetes_service_account.cloudwatch_agent,
    kubernetes_service_account.fluent_bit
  ]
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

  tags = merge(
    var.tags,
    {
      Name = "${each.value.name}-node"
      propagate_at_launch = true
    }
  )



  depends_on = [
    aws_eks_cluster.gmk-cluster
  ]
}
