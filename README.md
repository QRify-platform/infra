# QRify Infrastructure

This repo is the AWS and Kubernetes *control plane* for QRify: Terraform defines the cluster and platform services, and GitHub Actions applies them via OIDC (no long-lived AWS keys in CI).

App code, Helm values, and Argo CD app definitions live elsewhere (`qrify-web`, `qrify-web-api`, `cluster-state`). This repo builds the ground those apps run on.

## Two layers: bootstrap vs managed stack

Terraform is split on purpose so **destroy/rebuild does not wipe the foundation** that CI and DNS need.

| | Bootstrap (`bootstrap/`) | Managed stack (repo root) |
|---|---|---|
| **Job** | Trust, remote state, CI roles, public DNS zone | EKS, ingress, certs, platform Helm charts, app storage |
| **Lifecycle** | Rarely changed; survives cluster teardown | Applied/destroyed often for DR drills |
| **Who applies** | You, manually in `bootstrap/` | GitHub Actions (Apply / Destroy / Rebuild Platform) |

**Bootstrap** holds things that must outlive the cluster:

- S3 bucket for Terraform state
- GitHub OIDC provider (so Actions can assume roles)
- CI IAM roles (`QRifyTerraformRole`, ECR push, EKS access)
- Route53 hosted zone for `qrify-web.com` (nameservers stay stable at the registrar)

**Managed stack** holds things you are willing to recreate from scratch:

- VPC + EKS + node group
- ECR repos, S3 app bucket, API IRSA
- NGINX Ingress, ACM, DNS records pointing at the LB
- Argo CD, Argo Rollouts, Sealed Secrets

If everything lived in one state file, `terraform destroy` would also delete state storage, OIDC trust, and the DNS zone — breaking CI and domain delegation on every DR run.

## Why modules (not one big file)

Modules are boundaries by concern, not a single mega-IAM dump.

**Bootstrap modules** (`bootstrap/modules/`):

- `state-bucket` — Terraform remote state
- `github-oidc` — Actions → AWS trust
- `terraform-role` — what Apply/Destroy is allowed to do
- `ecr-push-role` / `eks-access-role` — narrower CI roles for image push and kubectl/Argo sync
- `dns` — long-lived hosted zone only (records for the LB live in the managed stack)

**Managed stack modules** (`modules/`):

- `eks`, `ecr`, `s3`, `api-irsa` — cluster and app-facing AWS
- `ingress` — NGINX + ACM + `qrify-web.com` / `dev.qrify-web.com` records
- `argocd`, `argo-rollouts`, `sealed-secrets` — platform controllers on the cluster

Root `main.tf` only wires modules together. IAM that belongs to a feature stays next to that feature (e.g. API IRSA next to S3), instead of one shared `modules/iam`.

## What CI runs

- **Terraform Apply / Plan / Destroy** — managed stack only
- **Rebuild Platform** — after a destroy: apply → seed images from `catalog/services.yaml` → Argo sync (`GH_DISPATCH_TOKEN` required)

Changing bootstrap (roles, zone, OIDC) means a local `terraform apply` in `bootstrap/` so CI picks up the new permissions or DNS foundation.
