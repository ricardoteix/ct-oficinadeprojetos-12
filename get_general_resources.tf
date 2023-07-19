data "aws_route53_zone" "domain" {
  count = var.has-domain ? 1 : 0
  name = var.hosted_zone_name
}

# Find a certificate that is issued
data "aws_acm_certificate" "issued" {
  count = var.has-domain ? 1 : 0
  domain   = var.certificate-domain
  statuses = ["ISSUED"]
}

