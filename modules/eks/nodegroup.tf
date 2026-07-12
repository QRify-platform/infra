resource "aws_eks_node_group" "qrify_nodes" {
  cluster_name    = aws_eks_cluster.qrify.name
  node_group_name = "qrify-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn

  subnet_ids = [
    aws_subnet.private["private-a"].id,
    aws_subnet.private["private-b"].id
  ]

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }

  # t3.small caps ~11 pods/node (ENI IPs); medium has headroom for Rollouts + apps.
  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_worker,
    aws_iam_role_policy_attachment.eks_nodes_ecr,
    aws_iam_role_policy_attachment.eks_nodes_cni
  ]
}