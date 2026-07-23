output "secrets_role_arn" {
  description = "ARN of QRifySecretsRole for secrets-manager CI / local apply."
  value       = aws_iam_role.secrets.arn
}

output "secrets_role_name" {
  value = aws_iam_role.secrets.name
}
