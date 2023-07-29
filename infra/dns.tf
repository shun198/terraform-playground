# # ------------------------------
# # DNS Configuration
# # ------------------------------
data "aws_route53_zone" "zone" {
  name = "${var.dns_zone_name}."
}

# # サブドメインを追加
# resource "aws_route53_record" "app" {
#   zone_id = data.aws_route53_zone.zone.zone_id
#   # lookupを使ってterraform.workspaceのworkspace名をもとにvar.subdomainの値を返す
#   name = "${lookup(var.subdomain, terraform.workspace)}.${data.aws_route53_zone.zone.name}"
#   # CNAME(1つのドメイン名を別のドメイン名にマッピングするレコード)を指定
#   type = "CNAME"
#   # 5分を指定
#   ttl = "300"

#   records = [aws_lb.app.dns_name]
# }

# resource "aws_acm_certificate" "cert" {
#   domain_name       = aws_route53_record.app.fqdn
#   # 自身がDNSの所有者だと証明するためのvalidationをする
#   validation_method = "DNS"

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}-acm-cert" })
#   )

#   # 今回は検証用のためcreate_before_destroy = trueを指定
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # DNSのバリデーション
# resource "aws_route53_record" "cert_validation" {
#   name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
#   type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
#   zone_id = data.aws_route53_zone.zone.zone_id
#   records = [
#     aws_acm_certificate.cert.domain_validation_options.0.resource_record_value
#   ]
#   ttl = "60"
# }


# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
# }
