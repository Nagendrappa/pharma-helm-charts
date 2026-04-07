#!/bin/bash
# cleanup-dev.sh
# Stops all dev services, deletes ArgoCD apps, pods, and secrets

set -e

NAMESPACE_DEV="dev"
NAMESPACE_ARGOCD="argocd"
APPS=("pharma-auth-dev" "pharma-ui-dev" "api-gateway-dev" "notification-dev" "catalog-dev")

echo "✅ Logging into AWS ECR..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 392646748223.dkr.ecr.us-east-1.amazonaws.com

echo "🧹 Deleting ArgoCD applications..."
for app in "${APPS[@]}"; do
  kubectl -n $NAMESPACE_ARGOCD delete application $app --ignore-not-found
done

echo "🧹 Deleting pods in dev namespace..."
kubectl delete pods --all -n $NAMESPACE_DEV || true

echo "🧹 Deleting services in dev namespace..."
kubectl delete svc --all -n $NAMESPACE_DEV || true

echo "🧹 Deleting deployments in dev namespace..."
kubectl delete deploy --all -n $NAMESPACE_DEV || true

echo "🧹 Deleting secrets (ECR, DB, JWT) in dev namespace..."
kubectl delete secret ecr-secret --ignore-not-found -n $NAMESPACE_DEV
kubectl delete secret db-credentials --ignore-not-found -n $NAMESPACE_DEV
kubectl delete secret jwt-secret --ignore-not-found -n $NAMESPACE_DEV

echo "🧹 Deleting configmaps in dev namespace..."
kubectl delete configmap --all -n $NAMESPACE_DEV || true

echo "✅ Cleanup complete. All dev services stopped."
