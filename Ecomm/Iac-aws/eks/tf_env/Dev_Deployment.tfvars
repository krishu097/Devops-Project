# Environment Configuration
aws_region   = "us-east-1"
project_name = "Ecomm"
environment  = "dev"

# VPC Configuration
vpc_cidr = "10.0.0.0/22"

# EKS Cluster Configuration
kubernetes_version = "1.32"


# Node Groups Configuration
node_groups = {
  example-node-group = {
    name           = "ecomm-dev-node-group"
    desired_size   = 2
    min_size       = 1
    max_size       = 3
    instance_types = ["t3.small"]
    labels = {
      role = "worker"
    }
  }
}
