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

# ECS内のCloudWatchの設定
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${local.prefix}-app"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-cloudwatch-logs" })
  )
}

data "template_file" "app_container_definitions" {
  template = file("./ecs/taskdef.json")

  vars = {
    app_image                = var.ecr_image_app
    proxy_image              = var.ecr_image_proxy
    django_secret_key        = var.django_secret_key
    db_host                  = aws_db_instance.main.address
    db_name                  = aws_db_instance.main.name
    db_user                  = aws_db_instance.main.username
    db_pass                  = aws_db_instance.main.password
    log_group_name           = aws_cloudwatch_log_group.ecs_task_logs.name
    log_group_region         = data.aws_region.current.name
    allowed_hosts            = aws_route53_record.app.fqdn
    s3_storage_bucket_name   = aws_s3_bucket.app_public_files.bucket
    s3_storage_bucket_region = data.aws_region.current.name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition.html#example-usage
resource "aws_ecs_task_definition" "app" {
  family                   = "${local.prefix}-app"
  container_definitions    = data.template_file.app_container_definitions.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  volume {
    name = "static"
  }

  tags = local.common_tags
}

resource "aws_security_group" "ecs_service" {
  description = "Access for the ECS Service"
  name        = "${local.prefix}-ecs-service"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_a.cidr_block,
      aws_subnet.private_c.cidr_block,
    ]
  }

  ingress {
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.lb.id
    ]
  }

  tags = local.common_tags
}

resource "aws_ecs_service" "app" {
  name             = "${local.prefix}-app"
  cluster          = aws_ecs_cluster.main.name
  task_definition  = aws_ecs_task_definition.app.family
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_c.id,
    ]
    security_groups = [aws_security_group.ecs_service.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "proxy"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.app_https]
}
