# DR Environment Configuration
aws_region = "us-west-1"
aws_region_rds_replica = "us-east-2"
project_name = "Ecomm"
environment = "dr-edfx"

# VPC Configuration
vpc_cidr = "10.1.0.0/22"

# EKS Cluster Configuration
kubernetes_version = "1.33"
ebs-addon-version = "v1.51.1-eksbuild.1"

# Node Groups Configuration
node_groups = {
  dr-node-group = {
    name           = "ecomm-dr-node-group"
    desired_size   = 2
    min_size       = 1
    max_size       = 3
    instance_types = ["t3.medium"]
    ami_type       = "AL2023_x86_64_STANDARD"
    disk_size      = 20
    capacity_type  = "ON_DEMAND"

    labels = {
      role = "worker"
    }
  }
}

db_username = "krish"
db_password = "Krish#1234"

# DR Configuration - deploy secondary resources
deploy_secondary = true

# GitHub Configuration for Auto-Trigger
github_token = "your-github-token-here"
github_repo  = "your-username/Devops-Project"

tags = {
  Environment = "dr-secondary"
  Project     = "ecomm-dr"
  ManagedBy   = "terraform"
}