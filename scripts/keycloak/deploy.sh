#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/../../" && pwd)"
kubectl apply -f "$ROOT_DIR/k8s/keycloak/secret.yaml" -n bidflow
kubectl apply -f "$ROOT_DIR/k8s/keycloak/realm-configmap.yaml" -n bidflow
kubectl apply -f "$ROOT_DIR/k8s/keycloak/deployment.yaml" -n bidflow
kubectl apply -f "$ROOT_DIR/k8s/keycloak/service.yaml" -n bidflow
kubectl wait --for=condition=available --timeout=180s deployment/keycloak -n bidflow
