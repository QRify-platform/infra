variable "buckets" {
  description = "Map of environment => S3 bucket name (private QR object storage)."
  type        = map(string)
}
