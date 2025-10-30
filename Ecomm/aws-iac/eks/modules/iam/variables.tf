variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {

    owner = "krishna"
  }
}
variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = true
}
variable "oidc_provider_url" {
  description = "OIDC Provider URL for the EKS cluster"
  type        = string

}
