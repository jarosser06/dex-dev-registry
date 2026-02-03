#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

BUILD_DIR="$PROJECT_ROOT/build"

echo "Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "Finding all package.hcl files..."
PACKAGE_FILES=$(find . -name "package.hcl" -type f)

if [ -z "$PACKAGE_FILES" ]; then
  echo "No package.hcl files found"
  exit 1
fi

echo "Packaging dex packages..."
for PACKAGE_FILE in $PACKAGE_FILES; do
  PACKAGE_DIR=$(dirname "$PACKAGE_FILE")
  echo "  Packaging $PACKAGE_DIR..."

  # Extract package name and version from package.hcl
  PACKAGE_NAME=$(grep -m1 'name' "$PACKAGE_FILE" | sed -E 's/.*"([^"]+)".*/\1/')
  PACKAGE_VERSION=$(grep -m1 'version' "$PACKAGE_FILE" | sed -E 's/.*"([^"]+)".*/\1/')

  OUTPUT_FILE="$BUILD_DIR/${PACKAGE_NAME}-${PACKAGE_VERSION}.tar.gz"

  (cd "$PACKAGE_DIR" && dex pack -o "$OUTPUT_FILE")
done

echo "Generating registry.json..."
python3 "$SCRIPT_DIR/generate-registry.py" > "$BUILD_DIR/registry.json"

echo "Build complete!"
echo "  Packages: $(ls -1 "$BUILD_DIR"/*.tar.gz 2>/dev/null | wc -l | tr -d ' ')"
echo "  Registry: $BUILD_DIR/registry.json"
