# Prefix delegation raises maxPods on t3.small (~11 → ~110) without larger instances.
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.qrify.name
  addon_name   = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
    }
  })

  depends_on = [
    aws_eks_cluster.qrify,
    aws_iam_role_policy_attachment.eks_nodes_cni
  ]
}
