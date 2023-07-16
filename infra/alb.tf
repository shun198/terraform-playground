# ------------------------------
# Load Balancer Configuration
# ------------------------------
resource "aws_lb" "app" {
  name               = "${local.prefix}-main"
  load_balancer_type = "application"
  subnets = [
    aws.subnet.public_a.id,
    aws.subnet.public_c.id
  ]

  security_groups = [aws_security_group.lb.id]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-alb-app" })
  )
}

# トラフィックを分散する箇所(グループ)
# 指定されたプロトコルとポート番号を使用して、ECSにリクエストをルーティングできる
resource "aws_lb_target_group" "app" {
  name        = "${local.prefix}-app"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  port        = 8000

  health_check {
    path = "api/health/"
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-alb-target-group" })
  )
}

# ロードバランサーへの入り口に当たる
# 設定したプロトコルとポートを使用して接続リクエストをチェック役割を持つ
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  # ターゲットグループへ
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-alb-listener" })
  )
}

resource "aws_security_group" "lb" {
  description = "Allow access to ALB"
  name        = "${local.prefix}-lb"
  vpc_id      = aws_vpc.main.id

  # ロードバランザーにインバウンドで入る
  ingress = {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ロードバランザーからアウトバウンドで出る
  egress = {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-alb-sg" })
  )
}
