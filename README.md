# QRify Infrastructure

Terraform + GitHub Actions for the QRify platform. Split into:

- **`bootstrap/`** — long-lived trust & state (S3 backend, GitHub OIDC, CI IAM roles, Route53 hosted zone)
- **Root stack** — EKS and everything that is destroyed/rebuilt with the cluster

## Stack (managed stack)

- EKS (`qrify-eks`) + VPC / node group
- ECR repos for web + API (dev/prod)
- S3 app storage + IRSA for the API
- NGINX Ingress + ACM TLS + Route53 records (`qrify-web.com`, `dev.qrify-web.com`)
- Argo CD, Argo Rollouts, Sealed Secrets
- (Apps + monitoring live in `cluster-state`)

## Tech

- Terraform (AWS / Helm / Kubernetes providers)
- AWS (`us-east-2`)
- GitHub Actions (OIDC → `QRifyTerraformRole`)

## Naming: bootstrap vs rebuild-platform

| | **`bootstrap/`** (Terraform) | **Rebuild Platform** (workflow) |
|---|---|---|
| **What** | Trust + state: S3 backend, GitHub OIDC, CI IAM, public DNS zone | Managed-stack DR: apply → seed images → Argo sync |
| **When** | Rarely (account/foundation changes) | After destroy / new cluster |
| **How** | Manual `terraform apply` in `bootstrap/` | Actions → **Rebuild Platform** |
| **Scope** | Prerequisites CI needs to exist | Does **not** recreate bootstrap |

## Bootstrap modules

```text
bootstrap/modules/
  state-bucket/     # terraform remote state
  github-oidc/      # Actions OIDC provider
  terraform-role/   # QRifyTerraformRole
  ecr-push-role/    # QRifyECRPushRole
  eks-access-role/  # QRifyEKSAccessRole
  dns/              # qrify-web.com hosted zone
```

## Rebuild Platform (Tier-1 DR)

After a fresh cluster (with bootstrap already in place), run **Actions → Rebuild Platform**. It:

1. Runs Terraform apply (EKS + Helm stack)
2. Triggers `release.dev` and `release.prod` for each service in `catalog/services.yaml` (prod here is DR seed only)
3. Triggers `cluster-state` Argo sync

Required secret: `GH_DISPATCH_TOKEN` (PAT/GitHub App with `actions:write` on the service and cluster-state repos).

After updating `QRifyTerraformPolicy` in `bootstrap/`, apply bootstrap Terraform once so CI picks up the new permissions.
