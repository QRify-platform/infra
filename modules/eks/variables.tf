variable "human_admin_principal_arns" {
  description = "IAM user/role ARNs that get AmazonEKSClusterAdminPolicy (for local kubectl)."
  type        = list(string)
  default     = []
}
