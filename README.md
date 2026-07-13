# 🏗️ QRify Infrastructure

This repository manages the infrastructure for the QRify platform using Terraform and GitHub Actions. It currently provisions foundational cloud resources like:

- Amazon ECR repositories for app container images
- S3 bucket for storing generated QR codes
- IAM roles and policies for secure access

More infrastructure components will be added incrementally as the platform evolves, including Kubernetes (EKS), Argo CD, monitoring, and more.

## 🚀 Tech Stack
- **Terraform**: Infrastructure as Code
- **AWS**: Cloud provider
- **GitHub Actions**: CI/CD automation

## Naming: bootstrap vs rebuild-platform

| | **`bootstrap/`** (Terraform) | **Rebuild Platform** (workflow) |
|---|---|---|
| **What** | Trust + state: S3 backend, GitHub OIDC, CI IAM roles | Managed-stack DR: apply → seed images → Argo sync |
| **When** | Rarely (account/foundation changes) | After destroy / new cluster |
| **How** | Manual `terraform apply` in `bootstrap/` | Actions → **Rebuild Platform** |
| **Scope** | Prerequisites CI needs to exist | Does **not** recreate bootstrap |

## Rebuild Platform (Tier-1 DR)

After a fresh cluster (with bootstrap already in place), run **Actions → Rebuild Platform**. It:

1. Runs Terraform apply (EKS + Helm stack)
2. Triggers `release.dev` and `release.prod` for each service in `catalog/services.yaml` (prod here is DR seed only)
3. Triggers `cluster-state` Argo sync

Required secret: `GH_DISPATCH_TOKEN` (PAT/GitHub App with `actions:write` on the service and cluster-state repos).

After updating `QRifyTerraformPolicy` in `bootstrap/` (e.g. OIDC destroy perms), apply that Terraform once so destroy can delete the EKS OIDC provider.
