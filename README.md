# QRify Infrastructure

This repo is the AWS and Kubernetes *control plane* for QRify: Terraform defines the cluster and platform services, and GitHub Actions applies them via OIDC (no long-lived AWS keys in CI).

App code, Helm values, and Argo CD app definitions live elsewhere (`qrify-web`, `qrify-web-api`, `cluster-state`). This repo builds the ground those apps run on.

## Two layers: bootstrap vs managed stack

Terraform is split on purpose so **destroy/rebuild does not wipe the foundation** that CI and DNS need.

| | Bootstrap (`bootstrap/`) | Managed stack (repo root) |
|---|---|---|
| **Job** | Trust, remote state, CI roles, public DNS zone | EKS, ingress, certs, Argo CD bootstrap, IRSA, app storage |
| **Lifecycle** | Rarely changed; survives cluster teardown | Applied/destroyed often for DR drills |
| **Who applies** | You, manually in `bootstrap/` | GitHub Actions (Apply / Destroy / Rebuild Platform) |

**Bootstrap** holds things that must outlive the cluster:

- S3 bucket for Terraform state
- GitHub OIDC provider (so Actions can assume roles)
- CI IAM roles (`QRifyTerraformRole`, ECR push, EKS access, **QRifySecretsRole**)
- KMS key `alias/qrify-secrets` for SOPS (secrets-manager repo)
- Route53 hosted zone for `qrify-web.com` (nameservers stay stable at the registrar)

**Managed stack** holds things you are willing to recreate from scratch:

- VPC + EKS + node group
- ECR repos, S3 app bucket, API IRSA, **External Secrets IRSA**, **ExternalDNS IRSA**
- NGINX Ingress, ACM, DNS records pointing at the LB (DNS moving to ExternalDNS next)
- Argo CD (bootstrap only)

Platform Helm addons (Rollouts, ESO, …) live in **`cluster-state/apps-infra`** via Argo CD — not Terraform `helm_release`.

App secret *values* live in the separate **`secrets-manager`** repo (SOPS → Secrets Manager) and survive cluster teardown. ESO re-syncs them into stable K8s Secret names after rebuild.

If everything lived in one state file, `terraform destroy` would also delete state storage, OIDC trust, and the DNS zone — breaking CI and domain delegation on every DR run.


Root `main.tf` only wires modules together. IAM that belongs to a feature stays next to that feature (e.g. API IRSA next to S3), instead of one shared `modules/iam`.

## What CI runs

- **Terraform Apply / Plan / Destroy** — managed stack only
- **Rebuild Platform** — after a destroy: apply → seed images from `catalog/services.yaml` → Argo sync (`GH_DISPATCH_TOKEN` required)

Changing bootstrap (roles, zone, OIDC) means a local `terraform apply` in `bootstrap/` so CI picks up the new permissions or DNS foundation.
