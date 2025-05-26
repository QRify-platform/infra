output "cluster_name" {
  value = aws_eks_cluster.qrify.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.qrify.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.qrify.certificate_authority[0].data
}
