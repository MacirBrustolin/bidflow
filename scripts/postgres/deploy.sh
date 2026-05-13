#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/../../" && pwd)"
kubectl apply -f "$ROOT_DIR/k8s/postgres/secret.yaml" -n bidflow
kubectl apply -f "$ROOT_DIR/k8s/postgres/deployment.yaml" -n bidflow
kubectl apply -f "$ROOT_DIR/k8s/postgres/service.yaml" -n bidflow
kubectl wait --for=condition=available --timeout=120s deployment/postgres -n bidflow
