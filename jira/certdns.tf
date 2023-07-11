module "acm" {
  source = "terraform-aws-modules/acm/aws"

  create_certificate = true
  domain_name        = "${var.jira_hostname}.${var.domain_name}"
  zone_id            = data.aws_route53_zone.dns-main.zone_id


  wait_for_validation = true
  validation_method   = "DNS"

  tags = {
    Name = "${var.project_name}-lb-cert"
  }
}
