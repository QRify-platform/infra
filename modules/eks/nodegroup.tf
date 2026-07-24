resource "aws_eks_node_group" "qrify_nodes" {
  cluster_name = aws_eks_cluster.qrify.name
  # Renamed so create_before_destroy can roll from t3.small → m7i-flex.large safely.
  node_group_name = "qrify-nodes-m7i"
  node_role_arn   = aws_iam_role.eks_nodes.arn

  subnet_ids = [
    aws_subnet.private["private-a"].id,
    aws_subnet.private["private-b"].id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  instance_types = ["m7i-flex.large"]

  labels = {
    "qrify.io/prefix-delegation" = "true"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_worker,
    aws_iam_role_policy_attachment.eks_nodes_ecr,
    aws_iam_role_policy_attachment.eks_nodes_cni,
    aws_eks_addon.vpc_cni
  ]
}
