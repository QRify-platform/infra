# Least-privilege RBAC for cluster-state CI (group qrify-eks-access).
# Scoped to the argocd namespace: manage Application CRs and read status.

resource "kubernetes_role_v1" "eks_access_argocd" {
  metadata {
    name      = "qrify-eks-access"
    namespace = "argocd"
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["applications", "applications/finalizers", "applications/status"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }

  depends_on = [module.argocd]
}

resource "kubernetes_role_binding_v1" "eks_access_argocd" {
  metadata {
    name      = "qrify-eks-access"
    namespace = "argocd"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.eks_access_argocd.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "qrify-eks-access"
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [module.argocd]
}
