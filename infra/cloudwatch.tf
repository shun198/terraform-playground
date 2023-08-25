# ECS内のCloudWatchの設定
# Django
resource "aws_cloudwatch_log_group" "app" {
  name = "${local.prefix}-app"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-cloudwatch-logs" })
  )
}

# Nginx
resource "aws_cloudwatch_log_group" "web" {
  name = "${local.prefix}-web"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-cloudwatch-logs" })
  )
}