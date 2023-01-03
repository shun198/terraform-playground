# ------------------------------
# Terraform configuration
# ------------------------------
terraform {
  # tfstateファイルを管理するようbackend(s3)を設定
  backend "s3" {
    bucket = "terraform-playground-for-cicd"
    key = "terrafrom-playground.tfstate"
    region = "ap-northeast-1"
    encrypt = true
  }
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
