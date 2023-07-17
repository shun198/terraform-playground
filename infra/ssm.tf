# resource "aws_ssm_parameter" "secret_key" {
#   name        = "${local.path}/SECRET_KEY"
#   description = "Secret Key for Django Application"
#   type        = "SecureString"
#   value       = "test"

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}_SECRET_KEY" })
#   )
# }

# resource "aws_ssm_parameter" "postgres_host" {
#   name        = "${local.path}/POSTGRES_HOST"
#   description = "Postgres Host Name"
#   type        = "String"
#   value       = aws_db_instance.main.address

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}_POSTGRES_HOST" })
#   )
# }

# resource "aws_ssm_parameter" "postgres_port" {
#   name        = "${local.path}/POSTGRES_PORT"
#   description = "Postgres Port Number"
#   type        = "String"
#   value       = aws_db_instance.main.port

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}_POSTGRES_PORT" })
#   )
# }

# resource "aws_ssm_parameter" "postgres_name" {
#   name        = "${local.path}/POSTGRES_NAME"
#   description = "Postgres DB Name"
#   type        = "String"
#   value       = aws_db_instance.main.db_name

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}_POSTGRES_NAME" })
#   )
# }

# resource "aws_ssm_parameter" "postgres_user" {
#   name        = "${local.path}/POSTGRES_USER"
#   description = "Postgres User Name"
#   type        = "SecureString"
#   value       = var.db_username

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}_POSTGRES_USER" })
#   )
# }

# resource "aws_ssm_parameter" "postgres_password" {
#   name        = "${local.path}/POSTGRES_PASSWORD"
#   description = "Postgres Password"
#   type        = "SecureString"
#   value       = var.db_password

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}_POSTGRES_PASSWORD" })
#   )
# }

# output "SECRET_KEY" {
#   value     = aws_ssm_parameter.secret_key.value
#   sensitive = true
# }

# output "POSTGRES_USER" {
#   value     = aws_ssm_parameter.postgres_user.value
#   sensitive = true
# }

# output "POSTGRES_PASSWORD" {
#   value     = aws_ssm_parameter.postgres_password.value
#   sensitive = true
# }