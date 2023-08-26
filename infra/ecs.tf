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

data "template_file" "app_container_definitions" {
  template = file("./templates/ecs/taskdef.json.tpl")

  vars = {
    log_group_name_app = aws_cloudwatch_log_group.app.name
    log_group_name_web = aws_cloudwatch_log_group.web.name
    ecr_image_app      = var.ecr_image_app
    ecr_image_web      = var.ecr_image_web

  }
}


# タスク定義
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition.html#example-usage
resource "aws_ecs_task_definition" "app" {
  family                   = "${local.prefix}-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  # 一旦手動でロールを付与してみる
  execution_role_arn    = "arn:aws:iam::044392971793:role/tf-pg-dev-task-exec-role"
  task_role_arn         = "arn:aws:iam::044392971793:role/tf-pg-dev-task-role"
  container_definitions = data.template_file.app_container_definitions.rendered

  volume {
    name = "tmp-data"
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-task-def" })
  )
}

# ECSのセキュリテーグループ
resource "aws_security_group" "ecs_sg" {
  description = "Access for the ECS Service"
  name        = "${local.prefix}-ecs-sg"
  vpc_id      = aws_vpc.main.id

  # ECSからPublicな通信へのアウトバウンドアクセスを許可
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # ECSからPostgresへのアウトバウンドアクセスを許可
  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_a.cidr_block,
      aws_subnet.private_c.cidr_block,
    ]
  }

  # Publicな通信からNginxへのインバウンドアクセスを許可
  # 全ての通信をNginxを経由させたいのでECSの8000ポートへ直接アクセスさせない
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [
      aws_security_group.lb.id
    ]
    # cidr_blocks = [
    #   "0.0.0.0/0"
    # ]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-sg" })
  )
}

resource "aws_ecs_service" "app" {
  name            = "${local.prefix}-app"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.app.family
  # 今回は検証用のためタスクを1つだけ実行させる
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_c.id,
    ]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-service" })
  )

  # ECS側にターゲットグループ内で新規タスクの作成を依頼する
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "web"
    container_port   = 80
  }

  # depends_on = [aws_lb_listener.app_https]
}
