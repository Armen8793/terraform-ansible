data "aws_acm_certificate" "my-existing-ssl" {
  domain      = var.domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
