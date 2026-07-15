variable "namespace" {
  type        = string
  default     = "ingress-nginx"
  description = "Namespace to install the ingress controller"
}

variable "ingress_chart_version" {
  type        = string
  default     = "4.10.0"
  description = "Helm chart version for the NGINX ingress controller"
}

variable "domain_name" {
  type        = string
  default     = "qrify-web.com"
  description = "Public apex domain (Route53 hosted zone must already exist in bootstrap)."
}

variable "dev_hostname" {
  type        = string
  default     = "dev.qrify-web.com"
  description = "Hostname for the /dev environment (SAN on the ACM cert + Route53 alias)."
}
