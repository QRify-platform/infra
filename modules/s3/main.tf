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
# Resource name kept as qrify_allow_public to match existing state (avoid moved + -target clash in CI).
resource "aws_s3_bucket_public_access_block" "qrify_allow_public" {
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
