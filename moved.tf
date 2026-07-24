moved {
  from = kubernetes_role_v1.eks_access_argocd
  to   = module.eks_access_rbac.kubernetes_role_v1.eks_access_argocd
}

moved {
  from = kubernetes_role_binding_v1.eks_access_argocd
  to   = module.eks_access_rbac.kubernetes_role_binding_v1.eks_access_argocd
}
