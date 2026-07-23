output "db_instance_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  value = aws_db_instance.this.address
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "security_group_id" {
  value = aws_security_group.rds.id
}

output "secret_arns" {
  description = "Secrets Manager ARNs for DATABASE_URL (per env)"
  value       = { for k, s in aws_secretsmanager_secret.database_url : k => s.arn }
}

output "secret_names" {
  value = { for k, s in aws_secretsmanager_secret.database_url : k => s.name }
}
