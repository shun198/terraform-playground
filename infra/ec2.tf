# ------------------------------
# EC2 Instance Configuration
# ------------------------------
resource "aws_instance" "app_server" {
  ami           = "ami-0bba69335379e17f8"
  instance_type = "t2.micro"

  # tagをoverrideしたいときはmergeを使う
  # 今回はlocal.common_tagsにNameタグを追加する形でoverrideする
  tags = merge(
    # common_tagとnameを合体させてつける
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ec2" })
  )
}
