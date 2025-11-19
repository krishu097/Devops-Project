aws_region = "us-west-2"
aws_region_rds_replica = "us-east-2"

project_name = "ecomm-dr"
environment = "dr-secondary"

vpc_cidr = "10.20.0.0/16"

kubernetes_version = "1.28"
ebs-addon-version = "v1.25.0-eksbuild.1"

cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

node_groups = {
  dr_nodes = {
    name           = "dr-worker-nodes"
    desired_size   = 2
    min_size       = 1
    max_size       = 4
    instance_types = ["t3.medium"]
    ami_type       = "AL2_x86_64"
    disk_size      = 20
    capacity_type  = "ON_DEMAND"
    labels = {
      Environment = "dr-secondary"
      NodeGroup   = "dr-workers"
    }
  }
}

db_instance_identifier = "ecomm-rds-instance"
db_instance_class = "db.t3.micro"
db_engine = "mysql"
db_engine_version = "8.0.37"
db_username = "admin"
db_password = "your-secure-password"

deploy_secondary = true

tags = {
  Environment = "dr-secondary"
  Project     = "ecomm-dr"
  ManagedBy   = "terraform"
}