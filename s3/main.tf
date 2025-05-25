resource "aws_s3_bucket" "qrify_storage" {
  bucket         = var.bucket_name
  force_destroy  = true

  tags = {
    Name        = var.bucket_name
    Environment = "dev"
  }
}

# Disable block public access so we can apply a public policy to /qr_codes/*
resource "aws_s3_bucket_public_access_block" "qrify_allow_public" {
  bucket                  = aws_s3_bucket.qrify_storage.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_cors_configuration" "qrify_cors" {
  bucket = aws_s3_bucket.qrify_storage.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}
