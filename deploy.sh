#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Parse command line arguments
DEPLOY_INFRA=false
CLEAN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --infra)
      DEPLOY_INFRA=true
      shift
      ;;
    --clean)
      CLEAN=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--infra] [--clean]"
      echo "  --infra: Deploy infrastructure (CloudFormation)"
      echo "  --clean: Clean build directory before packaging"
      exit 1
      ;;
  esac
done

# Deploy infrastructure if requested
if [ "$DEPLOY_INFRA" = true ]; then
  echo "==> Deploying infrastructure..."
  ./infrastructure/deploy.sh
  echo
fi

# Source infrastructure configuration
if [ ! -f infrastructure/config.sh ]; then
  echo "Error: infrastructure/config.sh not found"
  echo "Run with --infra flag first to deploy infrastructure"
  exit 1
fi

source infrastructure/config.sh

# Clean build directory if requested
if [ "$CLEAN" = true ]; then
  echo "==> Cleaning build directory..."
  rm -rf build/
  echo
fi

# Download existing registry.json from S3 to preserve old versions
echo "==> Downloading existing registry.json from S3..."
mkdir -p build/
if aws s3 cp "s3://$BUCKET_NAME/registry.json" build/registry-existing.json 2>/dev/null; then
  echo "✓ Found existing registry.json"
else
  echo "ℹ No existing registry.json found (this is normal for first deployment)"
fi
echo

# Package dex packages
echo "==> Packaging dex packages..."
./scripts/package.sh
echo

# Sync to S3 (preserves old versions)
echo "==> Syncing to S3..."
aws s3 sync build/ "s3://$BUCKET_NAME/" \
  --exclude ".DS_Store" \
  --exclude "*.swp"
echo

echo "==> Deployment complete!"
echo "Registry URL: $REGISTRY_URL"
echo "S3 URL: $S3_URL"
echo
echo "Test with:"
echo "  dex registry add dex-dev-registry $REGISTRY_URL"
echo "  dex install base-dev@0.1.0"
echo "  dex install tailwind-css@0.1.0"
