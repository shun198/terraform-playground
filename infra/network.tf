# ------------------------------
# VPC Configuration
# ------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  # DNSによる名前解決をサポートする
  enable_dns_support = true
  # パブリックIPアドレスを持つインスタンスが対応するDNSホスト名を取得できるよう明示する
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-vpc" })
  )
}

# ------------------------------
# Internert Gateway Configuration
# ------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-igw" })
  )
}

# ------------------------------
# Public Subnet Configuration
# ------------------------------
resource "aws_subnet" "public_a" {
  cidr_block = "10.0.1.0/24"
  # サブネットに配置されたインスタンスにパブリックIPアドレスが付与される
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${data.aws_region.current.name}a"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-a" })
  )
}

# ルートテーブルの設定
resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-a-rt" })
  )
}

# ルートテーブルをパブリックサブネットaと紐付ける
# タグをサポートしてないのでつけない
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

# IGWへのルーティングを設定
# タグをサポートしてないのでつけない
resource "aws_route" "public_internet_access_a" {
  route_table_id = aws_route_table.public_a.id
  # インターネット(0.0.0.0/0)へのアクセスを許可
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# NATゲートウェイ用のElasticIPをpublic_a内に作成
resource "aws_eip" "public_a" {
  vpc = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-a-eip" })
  )
}

# NATゲートウェイ
resource "aws_nat_gateway" "public_a" {
  # パブリックサブネットaに作成したElasticIPをNATに割り当てる(allocateする)
  allocation_id = aws_eip.public_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-a-ngw" })
  )
}

resource "aws_subnet" "public_b" {
  cidr_block = "10.0.2.0/24"
  # サブネットに配置されたインスタンスにパブリックIPアドレスが付与される
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${data.aws_region.current.name}b"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-b" })
  )
}
resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-b-rt" })
  )
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_b.id
}

resource "aws_route" "public_internet_access_b" {
  route_table_id         = aws_route_table.public_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_eip" "public_b" {
  vpc = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-b-eip" })
  )
}

resource "aws_nat_gateway" "public_b" {
  allocation_id = aws_eip.public_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-b-ngw" })
  )
}
# ------------------------------
# Private Subnet Configuration
# ------------------------------
resource "aws_subnet" "private_a" {
  cidr_block        = "10.0.11.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "${data.aws_region.current.name}a"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-a" })
  )
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-a-rt" })
  )
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route" "private_a_internet_out" {
  route_table_id = aws_route_table.private_a.id
  # インターネットへのアウトバウンドアクセスを可能にするためにNATの設定を行う
  nat_gateway_id         = aws_nat_gateway.public_a.id
  destination_cidr_block = "0.0.0.0/24"
}

resource "aws_subnet" "private_b" {
  cidr_block        = "10.0.12.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "${data.aws_region.current.name}b"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-b" })
  )
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-b-rt" })
  )
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_route" "private_b_internet_out" {
  route_table_id = aws_route_table.private_b.id
  # インターネットへのアウトバウンドアクセスを可能にするためにNATの設定を行う
  nat_gateway_id         = aws_nat_gateway.public_b.id
  destination_cidr_block = "0.0.0.0/24"
}
