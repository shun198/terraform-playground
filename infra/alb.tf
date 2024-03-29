# ------------------------------
# Load Balancer Configuration
# ------------------------------
resource "aws_lb" "app" {
  name = "${local.prefix}-main"
  # HTTPレベルでリクエストをハンドリングするALBを使用
  load_balancer_type = "application"
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id
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
  port        = 80

  health_check {
    path = "/api/health/"
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-alb-target-group" })
  )
}

# ロードバランサーの入り口に当たる
# 設定したプロトコルとポートを使用して接続リクエストをチェック役割を持つ
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  # ターゲットグループへ
  default_action {
    # ALBのリスナーからターゲットグループへforwardする
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  # ターゲットグループへ
  # HTTPで通信した場合はHTTPSへリダイレクトする
  # default_action {
  #   type             = "redirect"
  #   target_group_arn = aws_lb_target_group.app.arn

  #   redirect {
  #     port        = "443"
  #     protocol    = "HTTPS"
  #     status_code = "HTTP_301"
  #   }
  # }


  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-alb-listener" })
  )
}

# HTTPS用のリスナー(validationから取得)
resource "aws_lb_listener" "app_https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  # listenerを作成する前にACMのバリデーションを行う
  certificate_arn = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_security_group" "lb" {
  description = "Allow access to ALB"
  name        = "${local.prefix}-lb"
  vpc_id      = aws_vpc.main.id

  # Publicな通信からロードバランザーへインバウンドで入る
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ロードバランザーからECS(Nginx)へアウトバウンドで出る
  egress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-alb-sg" })
  )
}