# ------------------------------
# Bastion Server Configuration
# ------------------------------

data "aws_ami" "amazon_linux" {
  # 最新のamiを取得
  most_recent = true
  filter {
    name   = "name"
    values = ["${var.ami_image_for_bastion}"]
  }
  # Amazon公式のamiを取得
  owners = ["amazon"]
}

resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t2.micro"
  user_data            = file("./templates/bastion/user-data.sh")
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  key_name             = var.bastion_key_name
  subnet_id            = aws_subnet.public_a.id

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  # タグ付け
  # mergeを使うことで一部のmain.tfにあるcommon_tagsをoverrideできる
  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-bastion")
  )
}
