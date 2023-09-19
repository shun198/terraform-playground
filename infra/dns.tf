# ------------------------------
# DNS Configuration
# ------------------------------
# Route53本体の設定
data "aws_route53_zone" "zone" {
  # name = "${var.domain}."
  zone_id = "Z01363632DBYWMKH0PRLL"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-route-53-zone" })
  )
}

# サブドメインを追加
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.subdomain
  type    = "A"
  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }

  # records = [aws_lb.app.dns_name]
}

# ACMを作成
resource "aws_acm_certificate" "cert" {
  domain_name = var.domain
  # 自身がDNSの所有者だと証明するためのvalidationをする
  validation_method = "DNS"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-acm-cert" })
  )

  # 今回は検証用のためcreate_before_destroy = trueを指定
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    data.aws_route53_zone.zone
  ]
}

# DNSのバリデーション
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.zone.zone_id
}


resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
