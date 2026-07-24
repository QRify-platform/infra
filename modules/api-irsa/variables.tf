variable "oidc_provider_arn" {
  type        = string
  description = "EKS OIDC provider ARN"
}

variable "oidc_provider_url" {
  type        = string
  description = "EKS OIDC provider URL (https://...)"
}

variable "s3_bucket_names" {
  type        = map(string)
  description = "Map of environment => S3 bucket the API in that namespace may read/write"
}

variable "service_account_name" {
  type        = string
  description = "Kubernetes service account name used by the API"
  default     = "qrify-web-api"
}
