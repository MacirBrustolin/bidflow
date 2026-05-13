# scripts\build-and-load-images.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = (Resolve-Path "$PSScriptRoot\..").Path
$kindName = "bidflow"

Write-Host "[build] Building Docker images (multi-stage will run Maven inside build container)" -ForegroundColor Cyan

# Build config-server image
Write-Host " - building config-server image..."
docker build -t bidflow/config-server:0.0.1 "$root\config-server"

# Build api-gateway image
Write-Host " - building api-gateway image..."
docker build -t bidflow/api-gateway:0.0.1 "$root\api-gateway"

Write-Host "[kind] Loading images into kind cluster '$kindName'..." -ForegroundColor Cyan
kind load docker-image bidflow/config-server:0.0.1 --name $kindName
kind load docker-image bidflow/api-gateway:0.0.1 --name $kindName

Write-Host "Done." -ForegroundColor Green