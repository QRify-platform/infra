# Allow GitHub Actions (OIDC) Terraform role to talk to the Kubernetes API.
# Without this, helm/kubernetes providers get Unauthorized in CI.
data "aws_iam_role" "terraform" {
  name = "QRifyTerraformRole"
}

data "aws_iam_role" "eks_access" {
  name = "QRifyEKSAccessRole"
}

resource "aws_eks_access_entry" "terraform" {
  cluster_name  = aws_eks_cluster.qrify.name
  principal_arn = data.aws_iam_role.terraform.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "terraform_admin" {
  cluster_name  = aws_eks_cluster.qrify.name
  principal_arn = data.aws_iam_role.terraform.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.terraform]
}

# cluster-state CI: kubectl against the argocd namespace (root app + sync helpers)
resource "aws_eks_access_entry" "eks_access" {
  cluster_name  = aws_eks_cluster.qrify.name
  principal_arn = data.aws_iam_role.eks_access.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_access_argocd" {
  cluster_name  = aws_eks_cluster.qrify.name
  principal_arn = data.aws_iam_role.eks_access.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["argocd"]
  }

  depends_on = [aws_eks_access_entry.eks_access]
}
