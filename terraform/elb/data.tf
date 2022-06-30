data "aws_route53_zone" "api" {
  name = var.domain
}