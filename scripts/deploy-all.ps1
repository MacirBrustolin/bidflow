# scripts\deploy-all.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = (Resolve-Path "$PSScriptRoot\..").Path
$k8sDir = Join-Path $root "k8s"
$kindConfig = Join-Path $k8sDir "kind\config.yaml"
$namespaceFile = Join-Path $k8sDir "kind\namespace.yaml"

Write-Host "Ensure Docker Desktop is running and kind is installed." -ForegroundColor Yellow

# Create kind cluster if missing
$clusters = & kind get clusters 2>$null
if (-not ($clusters -match "bidflow")) {
  Write-Host "Creating kind cluster 'bidflow'..."
  kind create cluster --name bidflow --config $kindConfig
} else {
  Write-Host "Kind cluster 'bidflow' already exists."
}

# Build and load images
Write-Host "Building and loading images..."
& "$root\scripts\build-and-load-images.ps1"

# Create namespace
Write-Host "Applying namespace..."
kubectl apply -f $namespaceFile

# Deploy Postgres
Write-Host "Deploying Postgres..."
kubectl apply -f (Join-Path $k8sDir "postgres\secret.yaml") -n bidflow
kubectl apply -f (Join-Path $k8sDir "postgres\deployment.yaml") -n bidflow
kubectl apply -f (Join-Path $k8sDir "postgres\service.yaml") -n bidflow
kubectl wait --for=condition=available --timeout=120s deployment/postgres -n bidflow

# Deploy Keycloak
Write-Host "Deploying Keycloak..."
kubectl apply -f (Join-Path $k8sDir "keycloak\secret.yaml") -n bidflow
kubectl apply -f (Join-Path $k8sDir "keycloak\realm-configmap.yaml") -n bidflow
kubectl apply -f (Join-Path $k8sDir "keycloak\deployment.yaml") -n bidflow
kubectl apply -f (Join-Path $k8sDir "keycloak\service.yaml") -n bidflow
kubectl apply -f (Join-Path $k8sDir "keycloak\ingress.yaml") -n bidflow
kubectl wait --for=condition=available --timeout=180s deployment/keycloak -n bidflow

# Deploy Config Server
Write-Host "Deploying Config Server..."
kubectl apply -f (Join-Path $k8sDir "config-server\config-repo-configmap.yaml") -n bidflow
kubectl apply -f (Join-Path $k8sDir "config-server\deployment.yaml") -n bidflow
kubectl apply -f (Join-Path $k8sDir "config-server\service.yaml") -n bidflow
kubectl apply -f (Join-Path $k8sDir "config-server\ingress.yaml") -n bidflow
kubectl wait --for=condition=available --timeout=120s deployment/config-server -n bidflow

# Deploy API Gateway
Write-Host "Deploying API Gateway..."
kubectl apply -f (Join-Path $k8sDir "api-gateway\configmap.yaml") -n bidflow
kubectl apply -f (Join-Path $k8sDir "api-gateway\deployment.yaml") -n bidflow
kubectl apply -f (Join-Path $k8sDir "api-gateway\service.yaml") -n bidflow
kubectl apply -f (Join-Path $k8sDir "api-gateway\ingress.yaml") -n bidflow
kubectl wait --for=condition=available --timeout=120s deployment/api-gateway -n bidflow

Write-Host "Deploying Strimzi operator and example ephemeral Kafka cluster..." -ForegroundColor Yellow
kubectl create ns kafka --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "https://strimzi.io/install/latest?namespace=kafka" -n kafka
kubectl -n kafka rollout status deployment/strimzi-cluster-operator --timeout=120s
kubectl apply -n kafka -f "https://strimzi.io/examples/latest/kafka/kafka-ephemeral.yaml"
kubectl -n kafka wait kafka/my-cluster --for=condition=Ready --timeout=120s

Write-Host "Deploying KafkaUI..." -ForegroundColor Yellow
kubectl apply -f (Join-Path $k8sDir "kafka-ui\deployment.yaml") -n kafka
kubectl apply -f (Join-Path $k8sDir "kafka-ui\service.yaml") -n kafka
kubectl apply -f (Join-Path $k8sDir "kafka-ui\ingress.yaml") -n kafka
kubectl wait --for=condition=available --timeout=120s deployment/kafka-ui -n kafka

Write-Host "Deployment finished. Kafka-UI: http://kafka-ui.local Keycloak: http://keycloak.local  Gateway: http://api.local" -ForegroundColor Green