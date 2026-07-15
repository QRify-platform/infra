output "bucket_name" {
  value = aws_s3_bucket.qrify_storage.id
}

output "bucket_arn" {
  value = aws_s3_bucket.qrify_storage.arn
}
