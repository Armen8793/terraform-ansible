resource "aws_s3_bucket" "aca" {
  bucket = var.bucket 
  acl    = "public-read" 
  policy = file("s3_policy.json")
  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = "ACA"
  }

  lifecycle {
    prevent_destroy = false
  }
  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_object" "aca-website" {
  bucket = aws_s3_bucket.aca.id
  key = "index.html"
  source = "./index.html"
  server_side_encryption = "AES256"
}




