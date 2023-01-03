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

# ------------------------------
# Current AWS Region(ap-northeast-1)
# ------------------------------
# 現在のAWS Regionの取得方法
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region
data "aws_region" "current" {}
