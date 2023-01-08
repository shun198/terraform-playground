# ------------------------------
# Load Balancer Configuration
# ------------------------------
resource "aws_lb" "api" {
  name = "${local.prefix}-main"
  load_balancer_type = "application"
  subnets = [
    aws.subnet.public_a.id,
    aws.subnet.public_c.id
  ]

  security_groups = [aws_security_group.lb.id]

  tags = local.common_tags
}

resource "aws_lb_target_group" "api" {
  name = "${local.prefix}-api"
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  target_type = "ip"
  port = 8000

  health_check {
    path = "api/health/"
  }
}
