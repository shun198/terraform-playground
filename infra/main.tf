# ------------------------------
# Terraform configuration
# ------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# ------------------------------
# Provider
# ------------------------------
provider "aws" {
  region = "ap-northeast-1"
}

