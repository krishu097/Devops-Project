provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.gmk-cluster.token
}

provider "helm" {
  # Use the kubernetes provider configured above; nested "kubernetes" block is not supported by this helm provider version.
}

data "aws_eks_cluster_auth" "gmk-cluster" {
  name = module.eks.cluster_id
}
