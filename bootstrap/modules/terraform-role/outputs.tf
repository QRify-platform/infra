output "terraform_role_arn" {
  description = "ARN of the role assumed by GitHub Actions"
  value       = aws_iam_role.terraform.arn
}