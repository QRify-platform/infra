resource "aws_s3_bucket" "qrify_storage" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name      = var.bucket_name
    Project   = "QRify"
    ManagedBy = "Terraform"
  }
}

# Private bucket — API objects use IRSA + regional pre-signed URLs.
resource "aws_s3_bucket_public_access_block" "qrify" {
  bucket = aws_s3_bucket.qrify_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
