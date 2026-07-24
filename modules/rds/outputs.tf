output "db_instance_endpoints" {
  description = "Map of environment => RDS endpoint"
  value       = { for k, db in aws_db_instance.this : k => db.endpoint }
}

output "db_instance_addresses" {
  description = "Map of environment => RDS hostname"
  value       = { for k, db in aws_db_instance.this : k => db.address }
}

output "db_name" {
  description = "Database name on each instance"
  value       = var.db_name
}

output "master_username" {
  value = var.db_username
}

output "master_passwords" {
  description = "Map of environment => master password (also in DATABASE_URL secrets)"
  value       = { for k, p in random_password.master : k => p.result }
  sensitive   = true
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
