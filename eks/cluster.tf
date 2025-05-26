resource "aws_eks_cluster" "qrify" {
  name     = "qrify-eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.29"

  vpc_config {
    subnet_ids = concat(
      aws_subnet.public[*].id,
      aws_subnet.private[*].id
    )
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}
