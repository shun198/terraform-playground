resource "aws_ssm_parameter" "SECRET_KEY" {
  name        = "${local.path}/SECRET_KEY"
  description = "Secret Key for Django Application"
  type        = "SecureString"
  value       = "test"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}_SECRET_KEY" })
  )
}

resource "aws_ssm_parameter" "POSTGRES_HOST" {
  name        = "${local.path}/POSTGRES_HOST"
  description = "Postgres Host Name"
  type        = "String"
  value       = aws_db_instance.main.address

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}_POSTGRES_HOST" })
  )
}

resource "aws_ssm_parameter" "POSTGRES_PORT" {
  name        = "${local.path}/POSTGRES_PORT"
  description = "Postgres Port Number"
  type        = "String"
  value       = aws_db_instance.main.port

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}_POSTGRES_PORT" })
  )
}

resource "aws_ssm_parameter" "POSTGRES_NAME" {
  name        = "${local.path}/POSTGRES_NAME"
  description = "Postgres DB Name"
  type        = "String"
  value       = aws_db_instance.main.db_name

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}_POSTGRES_NAME" })
  )
}

resource "aws_ssm_parameter" "POSTGRES_USER" {
  name        = "${local.path}/POSTGRES_USER"
  description = "Postgres User Name"
  type        = "SecureString"
  value       = var.db_username

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}_POSTGRES_USER" })
  )
}

resource "aws_ssm_parameter" "POSTGRES_PASSWORD" {
  name        = "${local.path}/POSTGRES_PASSWORD"
  description = "Postgres Password"
  type        = "SecureString"
  value       = var.db_password

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}_POSTGRES_PASSWORD" })
  )
}

output "SECRET_KEY" {
  value     = aws_ssm_parameter.SECRET_KEY.value
  sensitive = true
}

output "POSTGRES_USER" {
  value     = aws_ssm_parameter.POSTGRES_USER.value
  sensitive = true
}

output "POSTGRES_PASSWORD" {
  value     = aws_ssm_parameter.POSTGRES_PASSWORD.value
  sensitive = true
}