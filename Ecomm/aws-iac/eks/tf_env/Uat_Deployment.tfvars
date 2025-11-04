# Environment Configuration
aws_region   = "us-east-2"
aws_region_rds_replica = "us-west-1"
project_name = "Ecomm"
environment  = "uat-edfx"

# VPC Configuration
vpc_cidr = "10.0.0.0/22"

# EKS Cluster Configuration
kubernetes_version = "1.33"

ebs-addon-version = "v1.51.1-eksbuild.1"


# Node Groups Configuration
node_groups = {
  example-node-group = {
    name           = "ecomm-uat-node-group"
    desired_size   = 2
    min_size       = 1
    max_size       = 3
    instance_types = ["t4g.medium"]
    ami_type       = "AL2023_ARM_64_STANDARD"
    disk_size      = 20
    capacity_type  = "ON_DEMAND"

    labels = {
      role = "worker"
    }
  }
}

db_username = "krish"
db_password = "Krish#1234"

