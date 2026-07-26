# Allow GitHub Actions (OIDC) roles to talk to the Kubernetes API.
#
# QRifyTerraformRole is NOT given an explicit access entry here: apply runs as
# that role with bootstrap_cluster_creator_admin_permissions = true, so EKS
# already creates the cluster-admin entry for the creator. Defining it again
# causes CreateAccessEntry 409 ResourceInUseException on every rebuild.

data "aws_iam_role" "eks_access" {
  name = "QRifyEKSAccessRole"
}

# cluster-state CI: map the role into a Kubernetes group. Permissions come from
# module.eks_access_rbac (argocd namespace only) — not EKS cluster-admin.
resource "aws_eks_access_entry" "eks_access" {
  cluster_name      = aws_eks_cluster.qrify.name
  principal_arn     = data.aws_iam_role.eks_access.arn
  type              = "STANDARD"
  kubernetes_groups = ["qrify-eks-access"]
}

# Local IAM users (e.g. admin) — AWS console "AdministratorAccess" is NOT
# enough for kubectl; EKS needs an access entry + policy.
resource "aws_eks_access_entry" "human_admins" {
  for_each = toset(var.human_admin_principal_arns)

  cluster_name  = aws_eks_cluster.qrify.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "human_admins" {
  for_each = toset(var.human_admin_principal_arns)

  cluster_name  = aws_eks_cluster.qrify.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.human_admins]
}
