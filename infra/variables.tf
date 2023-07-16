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
  default = "amzn2-ami-kernel-5.10-hvm-2.0.*-x86_64-gp2"
}

variable "bastion_key_name" {
  default = "terraform-playground-key-pair"
}

variable "ecr_image_app" {
  description = "ECR Image URI for Django App"
  default     = ""
}

variable "ecr_image_web" {
  description = "ECR Image URI for Nginx"
  default     = ""
}

variable "secret_key" {
  description = "Secret Key for Django"
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
