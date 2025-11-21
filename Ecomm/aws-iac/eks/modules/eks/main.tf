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
  count = var.deploy_secondary ? 1 : 0
  
  cluster_name  = aws_eks_cluster.gmk-cluster.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = var.ebs-addon-version

  service_account_role_arn = var.ebs_csi_driver_role

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  depends_on = [
    aws_eks_node_group.gmk-node-group
  ]
}

# CloudWatch Observability add-on for container insights
resource "aws_eks_addon" "cloudwatch_observability" {
  count = var.deploy_secondary ? 0 : 1
  
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
    aws_eks_node_group.gmk-node-group
  ]
}

resource "kubernetes_service_account" "ebs_csi_sa" {
  count = var.deploy_secondary ? 1 : 0
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.ebs_csi_driver_role
    }
  }
   depends_on = [
    aws_eks_cluster.gmk-cluster,
    aws_eks_node_group.gmk-node-group
  ]
}


resource "kubernetes_service_account" "ecr_pull_sa" {
  count = var.deploy_secondary ? 1 : 0
  metadata {
    name      = "ecr-pull-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.eks_ecr_access_role
    }
  }
   depends_on = [
    aws_eks_cluster.gmk-cluster,
    aws_eks_node_group.gmk-node-group
  ]
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  count = var.deploy_secondary ? 1 : 0
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.eks_aws_load_balancer_controller_role
    }
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
  }

  depends_on = [
    aws_eks_cluster.gmk-cluster,
    aws_eks_node_group.gmk-node-group
  ]
}

resource "aws_cloudwatch_log_group" "eks" {
  count = var.deploy_secondary ? 1 : 0
  
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
