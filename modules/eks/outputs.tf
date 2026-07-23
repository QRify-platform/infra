output "cluster_name" {
  value = aws_eks_cluster.qrify.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.qrify.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.qrify.certificate_authority.0.data
}



output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.oidc.url
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (nodes + private data plane)"
  value       = [for s in aws_subnet.private : s.id]
}

output "cluster_security_group_id" {
  description = "EKS cluster SG (also on nodes) — use as RDS ingress source"
  value       = aws_eks_cluster.qrify.vpc_config[0].cluster_security_group_id
}

output "s3_vpc_endpoint_id" {
  description = "Gateway VPC endpoint for S3 (private route tables)."
  value       = aws_vpc_endpoint.s3.id
}
