resource "aws_eks_node_group" "qrify_nodes" {
  cluster_name    = aws_eks_cluster.qrify.name
  node_group_name = "qrify-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [aws_subnet.private[0].id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.small"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_worker,
    aws_iam_role_policy_attachment.eks_nodes_ecr
  ]
}
