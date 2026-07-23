variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "domain_name" {
  description = "Public apex domain (Route53 hosted zone in bootstrap)."
  type        = string
  default     = "qrify-web.com"
}

variable "namespace" {
  type    = string
  default = "external-dns"
}

variable "service_account_name" {
  type    = string
  default = "external-dns"
}
