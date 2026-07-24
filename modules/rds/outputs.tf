output "db_instance_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  value = aws_db_instance.this.address
}

output "db_name" {
  description = "Bootstrap/admin database name on the instance"
  value       = aws_db_instance.this.db_name
}

output "app_database_names" {
  description = "Map of environment => application database name"
  value       = local.app_databases
}

output "master_username" {
  value = var.db_username
}

output "master_password" {
  description = "Master password (also embedded in per-env DATABASE_URL secrets)"
  value       = random_password.master.result
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
