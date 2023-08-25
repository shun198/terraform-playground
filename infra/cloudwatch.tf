# ECS内のCloudWatchの設定
# Django
resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/project/dev/app"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-cloudwatch-logs" })
  )
}

# Nginx
resource "aws_cloudwatch_log_group" "web" {
  name = "/ecs/project/dev/web"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-cloudwatch-logs" })
  )
}