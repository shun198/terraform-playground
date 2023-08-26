[
    {
        "name" : "app",
        "image" : "${ecr_image_app}",
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
        "secrets": [
            {
                "name" : "POSTGRES_USER",
                "valueFrom" : "arn:aws:ssm:ap-northeast-1:044392971793:parameter/tf-pg/dev/POSTGRES_USER"
            },
            {
                "name" : "DJANGO_SETTINGS_MODULE",
                "valueFrom" : "arn:aws:ssm:ap-northeast-1:044392971793:parameter/tf-pg/dev/DJANGO_SETTINGS_MODULE"
            },
            {
                "name" : "TRUSTED_ORIGINS",
                "valueFrom" : "arn:aws:ssm:ap-northeast-1:044392971793:parameter/tf-pg/dev/TRUSTED_ORIGINS"
            },
            {
                "name" : "POSTGRES_HOST",
                "valueFrom" : "arn:aws:ssm:ap-northeast-1:044392971793:parameter/tf-pg/dev/POSTGRES_HOST"
            },
            {
                "name" : "ALLOWED_HOSTS",
                "valueFrom" : "arn:aws:ssm:ap-northeast-1:044392971793:parameter/tf-pg/dev/ALLOWED_HOSTS"
            },
            {
                "name" : "SECRET_KEY",
                "valueFrom" : "arn:aws:ssm:ap-northeast-1:044392971793:parameter/tf-pg/dev/SECRET_KEY"
            },
            {
                "name" : "POSTGRES_PASSWORD",
                "valueFrom" : "arn:aws:ssm:ap-northeast-1:044392971793:parameter/tf-pg/dev/POSTGRES_PASSWORD"
            },
            {
                "name" : "POSTGRES_PORT",
                "valueFrom" : "arn:aws:ssm:ap-northeast-1:044392971793:parameter/tf-pg/dev/POSTGRES_PORT"
            },
            {
                "name" : "POSTGRES_NAME",
                "valueFrom" : "arn:aws:ssm:ap-northeast-1:044392971793:parameter/tf-pg/dev/POSTGRES_NAME"
            }
        ],
        "entryPoint" : [
            "/usr/local/bin/entrypoint.sh"
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
                "awslogs-group" : "${log_group_name_app}",
                "awslogs-region" : "ap-northeast-1",
                "awslogs-stream-prefix" : "app"
            }
        }
    },
    {
        "name" : "web",
        "image" : "${ecr_image_web}",
        "essential" : true,
        "portMappings" : [
        {
            "containerPort" : 80,
            "hostPort"      : 80,
            "protocol"      : "tcp"
        }
        ],
        "dependsOn" : [{
            "containerName" : "app",
            "condition"     : "START"
        }],
        "mountPoints" : [
        {
            "sourceVolume" : "tmp-data",
            "containerPath" : "/code/tmp"
        }
        ],
        "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
            "awslogs-group" : "${log_group_name_web}",
            "awslogs-region" : "ap-northeast-1",
            "awslogs-stream-prefix" : "web"
        }
        }
    }
]