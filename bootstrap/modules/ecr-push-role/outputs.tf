output "ecr_push_role_arn" {
  description = "ARN of the role assumed by GitHub Actions for ECR push"
  value       = aws_iam_role.ecr_push.arn
}
