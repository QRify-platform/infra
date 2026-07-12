variable "oidc_provider_arn" {
  type        = string
  description = "EKS OIDC provider ARN"
}

variable "oidc_provider_url" {
  type        = string
  description = "EKS OIDC provider URL (https://...)"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket the API may read/write"
}

variable "service_account_name" {
  type        = string
  description = "Kubernetes service account name used by the API"
  default     = "qrify-web-api"
}

variable "namespaces" {
  type        = list(string)
  description = "Namespaces allowed to assume this role via IRSA"
  default     = ["dev", "prod"]
}
