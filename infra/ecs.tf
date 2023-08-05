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

# # ECSのコンテナの設定
# data "template_file" "app_container_definitions" {
#   template = file("./templates/ecs/taskdef.json")

#   vars = {
#     DJANGO_IMAGE      = var.ecr_image_app
#     NGINX_IMAGE       = var.ecr_image_web
#     SECRET_KEY        = var.secret_key
#     POSTGRES_HOST     = aws_db_instance.main.address
#     POSTGRES_NAME     = aws_db_instance.main.db_name
#     POSTGRES_USER     = aws_db_instance.main.username
#     POSTGRES_PASSWORD = aws_db_instance.main.password
#     LOG_GROUP_NAME    = aws_cloudwatch_log_group.ecs_task_logs.name
#     LOG_GROUP_REGION  = data.aws_region.current.name
#     #  今回は検証用のためALBを作成するまでは一時的に全てのホストを許可する
#     ALLOWED_HOSTS = "*"
#     # allowed_hosts            = aws_route53_record.app.fqdn
#     # s3_storage_bucket_name   = aws_s3_bucket.app_public_files.bucket
#     # s3_storage_bucket_region = data.aws_region.current.name
#   }
# }

# タスク定義
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition.html#example-usage
resource "aws_ecs_task_definition" "app" {
  family                   = "${local.prefix}-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn            = "arn:aws:iam::044392971793:role/ECSTaskRole"
  execution_role_arn       = "arn:aws:iam::044392971793:role/ECSTaskExecutionRole"
  container_definitions = jsonencode(
    [
      {
        "name" : "app",
        "image" : "044392971793.dkr.ecr.ap-northeast-1.amazonaws.com/tf-pg/django",
        "cpu" : 0,
        "portMappings" : [
          {
            "name" : "app-8000-tcp",
            "containerPort" : 8000,
            "hostPort" : 8000,
            "protocol" : "tcp",
            "appProtocol" : "http"
          }
        ],
        "essential" : true,
        "entryPoint" : [
          "/usr/local/bin/entrypoint.sh"
        ],
        "environment" : [
          {
            "name" : "POSTGRES_USER",
            "value" : "postgres"
          },
          {
            "name" : "DJANGO_SETTINGS_MODULE",
            "value" : "project.settings.dev"
          },
          {
            "name" : "TRUSTED_ORIGINS",
            "value" : "http://localhost"
          },
          {
            "name" : "POSTGRES_HOST",
            "value" : "tf-pg-dev-db.c2hyqbdmazh5.ap-northeast-1.rds.amazonaws.com"
          },
          {
            "name" : "ALLOWED_HOSTS",
            "value" : "localhost 127.0.0.1 [::1]"
          },
          {
            "name" : "SECRET_KEY",
            "value" : "secretkey"
          },
          {
            "name" : "POSTGRES_PASSWORD",
            "value" : "postgres"
          },
          {
            "name" : "POSTGRES_PORT",
            "value" : "5432"
          },
          {
            "name" : "POSTGRES_NAME",
            "value" : "tf-pg-dev-db"
          }
        ],
        "mountPoints" : [],
        "workingDirectory" : "/code",
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : "/ecs/tf-pg-taskdef",
            "awslogs-region" : "ap-northeast-1",
            "awslogs-stream-prefix" : "ecs"
          },
          "secretOptions" : []
        }
      },
      {
        "name" : "web",
        "image" : "044392971793.dkr.ecr.ap-northeast-1.amazonaws.com/tf-pg/nginx",
        "essential" : true,
        "portMappings" = [
          {
            containerPort = 80
            hostPort      = 80
            protocol      = "tcp"
          }
        ]
        "dependsOn" = [{
          containerName = "app"
          condition     = "START"
        }]
        "mountPoints" : [],
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-create-group" : "true",
            "awslogs-group" : "/ecs/tf-pg-taskdef",
            "awslogs-region" : "ap-northeast-1",
            "awslogs-stream-prefix" : "ecs"
          },
          "secretOptions" : []
        }
      }
    ]
  )

  volume {
    name = "static"
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
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ECSからPostgresへのアウトバウンドアクセスを許可
  # egress {
  #   from_port = 5432
  #   to_port   = 5432
  #   protocol  = "tcp"
  #   cidr_blocks = [
  #     aws_subnet.private_a.cidr_block,
  #     aws_subnet.private_c.cidr_block,
  #   ]
  # }

  # Publicな通信からNginxへのインバウンドアクセスを許可
  # 全ての通信をNginxを経由させたいのでECSの8000ポートへ直接アクセスさせない
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # security_groups = [
    #   aws_security_group.lb.id
    # ]
    cidr_blocks = [
      "0.0.0.0/0"
    ]
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
      aws_subnet.public_a.id,
      aws_subnet.public_c.id,
    ]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ecs-service" })
  )

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.app.arn
  #   container_name   = "proxy"
  #   container_port   = 8000
  # }

  # depends_on = [aws_lb_listener.app_https]
}

# resource "aws_ecr_repository" "app" {
#   name = "${local.path}/app"

#   image_scanning_configuration {
#     scan_on_push = true
#   }

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}-ecr-app-repository" })
#   )
# }

# resource "aws_ecr_repository" "web" {
#   name = "${local.path}/web"

#   image_scanning_configuration {
#     scan_on_push = true
#   }

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}-ecr-app-repository" })
#   )
# }