resource "helm_release" "argo_rollouts" {
  name             = "argo-rollouts"
  namespace        = "argo-rollouts"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  version          = "2.40.10"
  create_namespace = true

  values = [
    <<-EOT
    dashboard:
      enabled: false
    EOT
  ]
}
