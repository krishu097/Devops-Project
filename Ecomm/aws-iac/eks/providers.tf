provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "replica"
  region = var.aws_region_rds_replica  # Replica region
}

data "aws_eks_cluster" "gmk-cluster" {
  name = module.eks.cluster_id

  depends_on = [
    module.eks
  ]
}

data "aws_eks_cluster_auth" "gmk-cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.gmk-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.gmk-cluster.token

  exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        data.aws_eks_cluster.gmk-cluster.name
      ]
    }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.gmk-cluster.endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.gmk-cluster.token

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        data.aws_eks_cluster.gmk-cluster.name
      ]
    }
  }
}

