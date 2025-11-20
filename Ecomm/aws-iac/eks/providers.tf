provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "replica"
  region = var.aws_region_rds_replica  # Replica region
}

data "aws_eks_cluster" "gmk-cluster" {
  count = var.deploy_secondary ? 1 : 0
  name  = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "gmk-cluster" {
  count = var.deploy_secondary ? 1 : 0
  name  = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = var.deploy_secondary ? data.aws_eks_cluster.gmk-cluster[0].endpoint : null
  cluster_ca_certificate = var.deploy_secondary ? base64decode(data.aws_eks_cluster.gmk-cluster[0].certificate_authority[0].data) : null
  token                  = var.deploy_secondary ? data.aws_eks_cluster_auth.gmk-cluster[0].token : null

  exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = var.deploy_secondary ? [
        "eks",
        "get-token",
        "--cluster-name",
        data.aws_eks_cluster.gmk-cluster[0].name
      ] : []
    }
}

provider "helm" {
  kubernetes {
    host                   = var.deploy_secondary ? data.aws_eks_cluster.gmk-cluster[0].endpoint : null
    cluster_ca_certificate = var.deploy_secondary ? base64decode(data.aws_eks_cluster.gmk-cluster[0].certificate_authority[0].data) : null
    token                  = var.deploy_secondary ? data.aws_eks_cluster_auth.gmk-cluster[0].token : null

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = var.deploy_secondary ? [
        "eks",
        "get-token",
        "--cluster-name",
        data.aws_eks_cluster.gmk-cluster[0].name
      ] : []
    }
  }
}

