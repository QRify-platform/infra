output "key_arn" {
  description = "KMS key ARN for SOPS (.sops.yaml creation_rules)."
  value       = aws_kms_key.secrets.arn
}

output "key_id" {
  description = "KMS key ID."
  value       = aws_kms_key.secrets.key_id
}

output "alias_arn" {
  description = "KMS alias ARN (alias/qrify-secrets)."
  value       = aws_kms_alias.secrets.arn
}

output "alias_name" {
  description = "KMS alias name."
  value       = aws_kms_alias.secrets.name
}
