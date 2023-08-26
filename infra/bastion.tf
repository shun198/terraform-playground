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
  # iam_instance_profile = aws_iam_instance_profile.bastion.name
  subnet_id            = aws_subnet.public_a.id

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-bastion" })
  )
}

resource "aws_security_group" "bastion" {
  description = "Control bastion inbound and outbound access"
  name        = "${local.prefix}-bastion"
  vpc_id      = aws_vpc.main.id

  # 踏み台サーバへのSSH接続を許可
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 踏み台サーバから最新のパッケージのダウンロードができるようにするため
  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DBへアクセスできるようにするため
  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_a.cidr_block,
      aws_subnet.private_c.cidr_block,
    ]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-bastion-sg" })
  )
}

