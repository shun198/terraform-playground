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
                "value" : "postgres"
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
                "awslogs-group" : "${log_group_name_app}",
                "awslogs-region" : "ap-northeast-1",
                "awslogs-stream-prefix" : "app"
            }
        }
    },
    {
        "name" : "web",
        "image" : "044392971793.dkr.ecr.ap-northeast-1.amazonaws.com/tf-pg/nginx",
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