#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/../../" && pwd)"
kubectl apply -f "$ROOT_DIR/k8s/namespace.yaml"
kubectl apply -f "$ROOT_DIR/k8s/config-server/config-repo-configmap.yaml" -n bidflow
kubectl apply -f "$ROOT_DIR/k8s/config-server/deployment.yaml" -n bidflow
kubectl apply -f "$ROOT_DIR/k8s/config-server/service.yaml" -n bidflow
kubectl wait --for=condition=available --timeout=120s deployment/config-server -n bidflow
