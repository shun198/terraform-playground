# # ------------------------------
# # Load Balancer Configuration
# # ------------------------------
# resource "aws_lb" "api" {
#   name               = "${local.prefix}-main"
#   load_balancer_type = "application"
#   subnets = [
#     aws.subnet.public_a.id,
#     aws.subnet.public_c.id
#   ]

#   security_groups = [aws_security_group.lb.id]

#   tags = local.common_tags
# }

# resource "aws_lb_target_group" "api" {
#   name        = "${local.prefix}-api"
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.main.id
#   target_type = "ip"
#   port        = 8000

#   health_check {
#     path = "api/health/"
#   }
# }

# # ロードバランサーへの入り口に当たる
# resource "aws_lb_listener" "api" {
#   load_balancer_arn = aws_lb.api.arn
#   port              = 80
#   protocol          = "HTTP"

#   # ターゲットグループへ
#   default_action {
#     type             = "forword"
#     target_group_arn = aws_lb_target_group.api.arn
#   }
# }

# resource "aws_security_group" "lb" {
#   description = "Allow access to ALB"
#   name        = "${local.prefix}-lb"
#   vpc_id      = aws_vpc.main.id

#   # ロードバランザーにインバウンドで入る
#   ingress = {
#     protocol    = "tcp"
#     from_port   = 80
#     to_port     = 80
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # ロードバランザーからアウトバウンドで出る
#   egress = {
#     protocol    = "tcp"
#     from_port   = 8000
#     to_port     = 8000
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = local.common_tags
# }
