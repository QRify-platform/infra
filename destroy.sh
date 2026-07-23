#!/usr/bin/env bash
# Local destroy: drain LBs (ExternalDNS removes app DNS as Services/Ingress go away), then full destroy.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

AWS_REGION="${AWS_REGION:-us-east-2}"
CLUSTER_NAME="${CLUSTER_NAME:-qrify-eks}"

aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME" >/dev/null

echo "==> Draining LoadBalancer services"
NAMESPACE_DIR="$(cd "$ROOT/../github-actions/eks-drain-loadbalancers" && pwd)"
if [[ -f "$NAMESPACE_DIR/drain.sh" ]]; then
  AWS_REGION="$AWS_REGION" CLUSTER_NAME="$CLUSTER_NAME" bash "$NAMESPACE_DIR/drain.sh"
else
  kubectl get svc -A -o json \
    | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "\(.metadata.namespace) \(.metadata.name)"' \
    | while read -r ns name; do
        kubectl delete svc -n "$ns" "$name" --wait=true --timeout=5m || true
      done
fi

echo "==> Full terraform destroy"
terraform destroy -auto-approve

echo "==> Destroy complete"
