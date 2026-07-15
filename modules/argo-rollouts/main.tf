resource "helm_release" "argo_rollouts" {
  name             = "argo-rollouts"
  namespace        = "argo-rollouts"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  version          = "2.40.10"
  create_namespace = true
  timeout          = 600
  # Helm does not uninstall CRDs; avoid hanging destroy on leftover CR instances.
  wait          = true
  wait_for_jobs = false

  values = [
    <<-EOT
    dashboard:
      enabled: true
      service:
        type: LoadBalancer
    installCRDs: true
    EOT
  ]
}
