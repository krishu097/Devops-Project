variable "aws_region" {
  description = "The AWS region to deploy the resources"
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


