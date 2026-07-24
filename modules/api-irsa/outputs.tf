output "role_arns" {
  description = "Map of environment => IRSA role ARN"
  value       = { for env, r in aws_iam_role.api : env => r.arn }
}

output "role_names" {
  value = { for env, r in aws_iam_role.api : env => r.name }
}
