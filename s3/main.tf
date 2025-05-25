resource "aws_s3_bucket" "qrify_storage" {
  bucket = var.bucket_name
  force_destroy = true

  tags = {
    Name        = var.bucket_name
    Environment = "dev"
  }
}

output "bucket_arn" {
  value = aws_s3_bucket.qrify_storage.arn
}