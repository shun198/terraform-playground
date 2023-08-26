# ------------------------------
# Variables
# ------------------------------

# プロジェクトを識別する一意の識別子
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
  default = "al2023-ami-2023.1.*-kernel-6.*-x86_64"
}

variable "ecr_image_app" {
  description = "ECR Image URI for Django App"
  default = "044392971793.dkr.ecr.ap-northeast-1.amazonaws.com/tf-pg/django"
}

variable "ecr_image_web" {
  description = "ECR Image URI for Nginx"
  default = "044392971793.dkr.ecr.ap-northeast-1.amazonaws.com/tf-pg/nginx"
}

variable "dns_zone_name" {
  description = "Domain Name"
}

variable "subdomain" {
  description = "SubDomain Per Account"
  type        = map(string)
  default = {
    prd = "api"
    stg = "api.stg"
    dev = "api.dev"
  }
}
