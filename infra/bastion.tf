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
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_a.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-bastion" })
  )
}
