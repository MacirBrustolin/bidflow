#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/../../" && pwd)"
kubectl apply -f "$ROOT_DIR/k8s/api-gateway/configmap.yaml" -n bidflow
kubectl apply -f "$ROOT_DIR/k8s/api-gateway/deployment.yaml" -n bidflow
kubectl apply -f "$ROOT_DIR/k8s/api-gateway/service.yaml" -n bidflow
kubectl wait --for=condition=available --timeout=120s deployment/api-gateway -n bidflow