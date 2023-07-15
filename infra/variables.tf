# ------------------------------
# Variables
# ------------------------------

# プロジェクトを識別する一意の識別子
variable "aws-default-region" {
  default = "ap-northeast-1"
}

variable "prefix" {
  default = "tf-pg"
}

variable "project" {
  default = "terraform-playground"
}

variable "owner" {
  default = "shun198"
}

variable "db_username" {
  description = "Username for RDB MySQL Instance"
}

variable "db_password" {
  description = "Password for RDB MySQL Instance"
}

variable "ami_image_for_bastion" {
  description = "amzn2-ami-kernel-5.10-hvm-2.0.*-x86_64-gp2"
}

variable "bastion_key_name" {
  description = "terraform-playground-key-pair"
}

