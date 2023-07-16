resource "aws_ssm_parameter" "SECRET_KEY" {
  name        = "SECRET_KEY"
  description = "Secret Key for Django Application"
  type        = "SecureString"
  value       = "test"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}_SECRET_KEY" })
  )
}

output "SECRET_KEY_VALUE" {
  value     = aws_ssm_parameter.SECRET_KEY.value
  sensitive = true
}