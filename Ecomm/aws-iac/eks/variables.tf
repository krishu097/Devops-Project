variable "aws_region" {
  description = "The AWS region to deploy the resources"
  type        = string

}

variable "aws_region_rds_replica" {
  description = "The AWS region for RDS read replica"
  type        = string

}

variable "project_name" {
  description = "The name of the project"
  type        = string

}

variable "environment" {
  description = "The environment for the deployment"
  type        = string

}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string


}
variable "kubernetes_version" {
  description = "The version of Kubernetes to use"
  type        = string

}
variable "cluster_enabled_log_types" {
  description = "The log types to enable for the EKS cluster"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "ebs-addon-version" {
  description = "EBS CSI Driver Addon Version"
  type        = string

}

variable "node_groups" {
  description = "A map of node group configurations"
  type = map(object({
    name           = string
    desired_size   = number
    min_size       = number
    max_size       = number
    instance_types = list(string)
    ami_type       = string
    disk_size      = number
    capacity_type  = string
    labels         = map(string)
  }))


}


variable "db_instance_identifier" {
  description = "The RDS DB instance identifier"
  type        = string
  default     = "ecomm-rds-instance"
}

variable "db_instance_class" {
  description = "The RDS DB instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_engine" {
  description = "The RDS DB engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "The RDS DB engine version"
  type        = string
  default     = "8.0.37"
}

variable "db_username" {
  description = "The RDS DB master username"
  type        = string
  sensitive   = true
}
variable "db_password" {
  description = "The RDS DB master password"
  type        = string
  sensitive   = true
}

variable "deploy_secondary" {
  description = "Deploy secondary region resources for DR"
  type        = bool
  default     = false
}

variable "github_token" {
  description = "GitHub token for DR auto-trigger"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository for DR pipeline (owner/repo)"
  type        = string
}
