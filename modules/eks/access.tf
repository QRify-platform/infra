# Allow GitHub Actions (OIDC) Terraform role to talk to the Kubernetes API.
# Without this, helm/kubernetes providers get Unauthorized in CI.
data "aws_iam_role" "terraform" {
  name = "QRifyTerraformRole"
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
