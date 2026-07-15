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
