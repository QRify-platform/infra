output "eks_access_role_arn" {
  description = "ARN of the role assumed by GitHub Actions for EKS / Argo CD sync"
  value       = aws_iam_role.eks_access.arn
}
