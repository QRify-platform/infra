
resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets"
  namespace  = "sealed-secrets"
  chart      = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  version    = "2.15.4"
  create_namespace = true

  depends_on = [ var.cluster_name ]
}
