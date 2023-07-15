# ------------------------------
# ECS Configuration
# ------------------------------
resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-cluster"

  tags = merge(
  local.common_tags,
  tomap({ "Name" = "${local.prefix}-ecs-cluster" })
  )
}

