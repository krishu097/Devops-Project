# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  azs                = local.azs
  environment        = var.environment
  project_name       = var.project_name
  enable_nat_gateway = true
  #single_nat_gateway     = false
  one_nat_gateway_per_az = false

  tags = local.common_tags
}


# IAM Module
module "iam" {
  source = "./modules/iam"

  name_prefix       = local.name_prefix
  oidc_provider_url = module.eks.cluster_oidc_issuer_url

  tags = local.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name      = local.cluster_name
  cluster_version   = var.kubernetes_version
  cluster_log_types = var.cluster_enabled_log_types
  #Vpc
  subnet_ids    = module.vpc.private_subnets
  cluster_sg_id = module.vpc.cluster_security_group_id

  # IAM roles
  cluster_iam_role_arn = module.iam.cluster_iam_role_id
  node_iam_role_arn    = module.iam.node_iam_role_id

  # Node Groups
  node_groups = var.node_groups
  tags        = local.common_tags
}
