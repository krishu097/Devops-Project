# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name_prefix            = local.name_prefix
  vpc_cidr               = var.vpc_cidr
  azs                    = local.azs
  project_name           = var.project_name
  enable_nat_gateway     = true
  single_nat_gateway     = true
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
  cluster_iam_role_arn = module.iam.cluster_iam_role_arn
  node_iam_role_arn    = module.iam.node_iam_role_arn
  eks_ecr_access_role  = module.iam.eks_access_ecr_role_arn
  ebs_csi_driver_role  = module.iam.ebs_csi_driver_role_arn


  # Node Groups
  node_groups       = var.node_groups
  ebs-addon-version = var.ebs-addon-version
  tags              = local.common_tags
}

module "rds" {
  source = "./modules/rds"

  providers = {
    aws.replica = aws.replica
  }

  name_prefix            = local.name_prefix
  aws_region_rds_replica = var.aws_region_rds_replica
  db_instance_identifier = var.db_instance_identifier
  db_username            = var.db_username
  db_password            = var.db_password

  db_engine_version      = var.db_engine_version
  db_instance_class      = var.db_instance_class
  db_engine              = var.db_engine
  db_subnet_group_name   = module.vpc.db_subnet_group_name
  rds_monitoring_role_arn = module.iam.rds_monitoring_role_arn
  db_security_group_id    = [module.vpc.mysql_security_group_id]

  replica_db_subnet_group_name = module.vpc.replica_db_subnet_group_name

}
