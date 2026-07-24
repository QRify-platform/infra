resource "aws_s3_bucket" "qrify_storage" {
  for_each = var.buckets

  bucket        = each.value
  force_destroy = true

  tags = {
    Name        = each.value
    Project     = "QRify"
    ManagedBy   = "Terraform"
    Environment = each.key
  }
}

# Private bucket — API objects use IRSA + regional pre-signed URLs.
resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.qrify_storage

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "qrify_cors" {
  for_each = aws_s3_bucket.qrify_storage

  bucket = each.value.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}
