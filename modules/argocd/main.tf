

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "10.1.3"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
