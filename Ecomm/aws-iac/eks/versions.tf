terraform {
  required_version = ">= 1.0"

  backend "s3" {
    # Placeholders - real values come from backend config file
    bucket         = "placeholder"
    key            = "placeholder"
    region         = "placeholder"
    encrypt        = true
    dynamodb_table = "placeholder"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}
