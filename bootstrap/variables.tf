variable "aws_region" {
  description = "AWS region where QRify infrastructure will be deployed."
  type        = string
  default     = "us-east-2"
}

variable "terraform_state_bucket_name" {
  description = "Name of the Terraform state bucket."
  type        = string
  default     = "qrify-terraform-state"
}

variable "github_organization" {
  description = "GitHub organization or username."
  type        = string
  default     = "QRify-platform"
}

variable "github_repository" {
  description = "GitHub repository that can assume the Terraform role."
  type        = string
  default     = "infra"
}

variable "eks_access_github_repositories" {
  description = "GitHub repositories that can assume the EKS access role for kubectl / Argo CD sync."
  type        = list(string)
  default = [
    "cluster-state",
  ]
}

variable "domain_name" {
  description = "Public apex domain for QRify (Route53 hosted zone; registrar points NS here)."
  type        = string
  default     = "qrify-web.com"
}
