# ------------------------------
# Database Configuration
# ------------------------------
# RDSが使用するプライベートサブネットを設定
resource "aws_db_subnet_group" "main" {
  name = "${local.prefix}-main"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-main" })
  )
}

# セキュリティグループを設定
resource "aws_security_group" "rds" {
  description = "Allow access to RDB instance"
  name        = "${local.prefix}-rds-inbound-access"
  vpc_id      = aws_vpc.main.id

  # インバウンドのアクセスのみ許可
  ingress {
    protocol  = "tcp"
    from_port = 3306
    to_port   = 3306
  }

  tags = local.common_tags
}

resource "aws_db_instance" "main" {
  identifier        = "${local.prefix}-db"
  db_name           = "tfplaygrounddb"
  allocated_storage = 10
  storage_type      = "gp2"
  # https://qiita.com/uproad3/items/47494621290b4ffad39f
  engine               = "aurora-mysql"
  engine_version       = "8.0.mysql_aurora.3.02.2"
  instance_class       = "db.r5.large"
  db_subnet_group_name = aws_db_subnet_group.main.name
  username             = var.db_username
  password             = var.db_password
  # 0日。本番環境では設定する必要があるが今回は検証用のため0にする
  backup_retention_period = 0
  # 今回は検証用のためfalseにする
  multi_az = false
  # DBが削除された時スナップショットを取得する
  # 今回は検証用のためfalseにする(falseにすることで何度も検証できる)
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-main" })
  )
}
