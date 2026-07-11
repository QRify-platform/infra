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
