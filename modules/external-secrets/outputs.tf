output "role_arn" {
  description = "IRSA role ARN for External Secrets Operator."
  value       = aws_iam_role.eso.arn
}

output "namespace" {
  value = var.namespace
}

output "service_account_name" {
  value = var.service_account_name
}
