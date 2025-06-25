resource "aws_route53_zone" "internal" {
  name          = var.internal_root_domain
  force_destroy = true

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_zone" "public" {
  count = local.enable_public_route53_zone ? 1 : 0

  name          = var.public_root_domain
  force_destroy = true
}

resource "aws_route53_record" "caa" {
  count = local.enable_public_route53_zone ? 1 : 0

  zone_id = aws_route53_zone.public[0].zone_id
  name    = var.public_root_domain
  type    = "CAA"
  ttl     = 300
  records = [
    "0 issue \"letsencrypt.org\"",
    "0 issue \"amazon.com\"",
    "0 issue \"amazonaws.com\"",
    "0 issue \"amazontrust.com\"",
  ]
}
