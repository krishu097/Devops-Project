variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string

}

variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string

}

variable "cluster_iam_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "cluster_sg_id" {
  description = "The security group ID for the EKS cluster"
  type        = string
}

variable "cluster_log_types" {
  description = "The log types to enable for the EKS cluster"
  type        = list(string)
}

variable "ebs_csi_driver_role" {
  description = "ebs csi driver role arn"
  type        = string
}

variable "eks_ecr_access_role" {
  description = "ecr access role arn"
  type        = string
}
variable "ebs-addon-version" {
  description = "EBS CSI Driver Addon Version"
  type        = string

}

variable "node_groups" {
  description = "The node groups for the EKS cluster"
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

variable "node_iam_role_arn" {
  description = "The ARN of the IAM role for the EKS nodes"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    owner = "krishna"
  }

}

variable "eks_aws_load_balancer_controller_role" {
  description = "aws load balancer controller role arn"
  type        = string
}

variable "deploy_secondary" {
  description = "Deploy secondary region EKS cluster for DR"
  type        = bool
  default     = false
}
variable "github_repo" {
  description = "GitHub repository for DR webhook"
  type        = string
  default     = "your-username/Devops-Project"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}