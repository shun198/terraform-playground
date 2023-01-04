# ------------------------------
# Terraform configuration
# ------------------------------
terraform {
  # tfstateファイルを管理するようbackend(s3)を設定
  # https://developer.hashicorp.com/terraform/language/settings/backends/configuration
  backend "s3" {
    bucket  = "terraform-playground-for-cicd"
    key     = "terrafrom-playground.tfstate"
    region  = "ap-northeast-1"
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
# Locals
# ------------------------------
locals {
  # var.prefixはvariables.tfから取得
  # terraform.workspaceはterraform workspace listから該当するworkspace(dev,stg,prdなど)を取得
  prefix = "${var.prefix}-${terraform.workspace}"
  common_tags = {
    Environmnet = terraform.workspace
    Project = var.project
    Owner = var.owner
    ManagedBy = "Terraform"
  }
}

# ------------------------------
# Current AWS Region(ap-northeast-1)
# ------------------------------
# 現在のAWS Regionの取得方法
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region
data "aws_region" "current" {}
