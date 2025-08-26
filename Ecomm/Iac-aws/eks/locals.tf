data "aws_availability_zones" "available" {
  state = "available"
}

locals {

  name_prefix = "${var.project_name}-${var.environment}"

  # Common tags
  common_tags = merge({
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }, var.tags)


  azs = slice(data.aws_availability_zones.available.names, 0, 2)


  cluster_name = "${local.name_prefix}-cluster"
}


