# Environment Configuration
aws_region   = "us-east-2"
project_name = "Ecomm"
environment  = "dev"

# VPC Configuration
vpc_cidr = "10.0.0.0/22"

# EKS Cluster Configuration
kubernetes_version = "1.32"
ebs-addon-version  = "v1.32.0-eksbuild.1"

# Node Groups Configuration
node_groups = {
  example-node-group = {
    name           = "ecomm-dev-node-group"
    desired_size   = 2
    min_size       = 1
    max_size       = 3
    instance_types = ["t3.medium"]
    ami_type       = "AL2_x86_64"
    disk_size      = 20
    capacity_type  = "ON_DEMAND"

    labels = {
      role = "worker"
    }
  }
}

db_username = "admin"
db_password = "your-secure-password"

deploy_secondary = true
