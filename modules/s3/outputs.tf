output "bucket_names" {
  description = "Map of environment => bucket id/name"
  value       = { for env, b in aws_s3_bucket.qrify_storage : env => b.id }
}

output "bucket_arns" {
  description = "Map of environment => bucket ARN"
  value       = { for env, b in aws_s3_bucket.qrify_storage : env => b.arn }
}
