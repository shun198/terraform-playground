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

# タスク定義
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition.html#example-usage
resource "aws_ecs_task_definition" "app" {
  family                   = "${local.prefix}-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  # task_role_arn = "arn:aws:iam::044392971793:role/ECSTaskRole"
  # container_definitions = file("container_definitions/app_container_definitions.json")
  container_definitions = jsonencode(
    [
      {
        "name" : "app",
        "image" : "044392971793.dkr.ecr.ap-northeast-1.amazonaws.com/tf-pg/django",
        "cpu" : 0,
        "portMappings" : [
          {
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
            "value" : "*"
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
        "mountPoints" : [
          {
            "sourceVolume" : "tmp-data",
            "containerPath" : "/code/tmp"
          }
        ],
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : "/ecs/project/dev/app",
            "awslogs-region" : "ap-northeast-1",
            "awslogs-stream-prefix" : "app"
          },
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
        "mountPoints" : [
          {
            "sourceVolume" : "tmp-data",
            "containerPath" : "/code/tmp"
          }
        ],
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : "/ecs/project/dev/web",
            "awslogs-region" : "ap-northeast-1",
            "awslogs-stream-prefix" : "web"
          },
        }
      }
    ]
  )

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
