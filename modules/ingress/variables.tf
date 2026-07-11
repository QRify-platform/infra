variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Namespace to install the ingress controller"
}

variable "ingress_chart_version" {
  type        = string
  default     = "4.10.0"
  description = "Helm chart version for the NGINX ingress controller"
}

variable "oidc_provider_arn" {
  type        = string
  description = "The ARN of the IAM OIDC provider for the EKS cluster"
}


variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}