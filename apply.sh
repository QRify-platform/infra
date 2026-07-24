#!/usr/bin/env bash
# Two-pass apply so EKS exists before Helm/Kubernetes providers need it.
# Usage (from infra/): ./apply.sh
set -euo pipefail

cd "$(dirname "$0")"

echo "==> Pass 1/2: create/update EKS"
terraform apply -target=module.eks -auto-approve

echo "==> Pass 2/2: apply full stack (Helm charts, etc.)"
terraform apply -auto-approve

echo "==> Done"
