resource "aws_cloudfront_origin_access_identity" "aca-task-oai" {
  comment = "a CF origin access identifier for ${var.domain}"
}


resource "aws_cloudfront_distribution" "aca-cf-dist" {
  enabled             = true
  aliases             = [var.domain]
  default_root_object = "./index.html"

  origin {
    domain_name = aws_s3_bucket.aca.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.aca.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.aca-task-oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_s3_bucket.aca.id
    viewer_protocol_policy = "redirect-to-https" 
    forwarded_values {
      headers      = []
      query_string = true

      cookies {
        forward = "all"
      }
    }

  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  tags = {
    "Project"   = "Aca-task"
    "ManagedBy" = "Terraform"
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.my-existing-ssl.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}
