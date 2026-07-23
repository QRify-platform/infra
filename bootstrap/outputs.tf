output "terraform_role_arn" {
  description = "ARN of the role assumed by GitHub Actions"
  value       = module.terraform_role.terraform_role_arn
}

output "ecr_push_role_arn" {
  description = "ARN of the role assumed by GitHub Actions for ECR push"
  value       = module.ecr_push_role.ecr_push_role_arn
}

output "eks_access_role_arn" {
  description = "ARN of the role assumed by GitHub Actions for EKS / Argo CD sync"
  value       = module.eks_access_role.eks_access_role_arn
}

output "route53_zone_id" {
  description = "Hosted zone ID for the public QRify domain."
  value       = module.dns.route53_zone_id
}

output "route53_name_servers" {
  description = "Set these as custom nameservers at the registrar (domains.com)."
  value       = module.dns.route53_name_servers
}

output "route53_domain_name" {
  description = "Apex domain managed by this hosted zone."
  value       = module.dns.route53_domain_name
}

output "secrets_role_arn" {
  description = "ARN of QRifySecretsRole for the secrets-manager repo."
  value       = module.secrets_role.secrets_role_arn
}

output "secrets_kms_key_arn" {
  description = "KMS key ARN for SOPS (.sops.yaml in secrets-manager)."
  value       = module.secrets_kms.key_arn
}

output "secrets_kms_alias" {
  description = "KMS alias for SOPS."
  value       = module.secrets_kms.alias_name
}
