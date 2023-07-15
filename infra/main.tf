# ------------------------------
# Terraform configuration
# ------------------------------
terraform {
  # tfstateファイルを管理するようbackend(s3)を設定
  # https://developer.hashicorp.com/terraform/language/settings/backends/configuration
  backend "s3" {
    bucket         = "${var.project}-for-cicd"
    key            = "${var.project}.tfstate"
    region         = var.aws-default-region
    encrypt        = true
    dynamodb_table = "${var.project}-tf-state-lock"
  }
  # プロバイダを設定
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  # Terraformのバージョン制約
  required_version = ">= 1.2.0"
}

# ------------------------------
# Provider
# ------------------------------
# プロバイダ(AWS)を指定
provider "aws" {
  region = var.aws-default-region
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
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# ------------------------------
# Current AWS Region(ap-northeast-1)
# ------------------------------
# 現在のAWS Regionの取得方法
data "aws_region" "current" {}
