resource "aws_eks_node_group" "qrify_nodes" {
  cluster_name    = aws_eks_cluster.qrify.name
  node_group_name = "qrify-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn

  subnet_ids = [
    aws_subnet.private["private-a"].id,
    aws_subnet.private["private-b"].id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  # Free-tier friendly size; pod density comes from VPC CNI prefix delegation.
  instance_types = ["t3.small"]

  labels = {
    "qrify.io/prefix-delegation" = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_worker,
    aws_iam_role_policy_attachment.eks_nodes_ecr,
    aws_iam_role_policy_attachment.eks_nodes_cni,
    aws_eks_addon.vpc_cni
  ]
}