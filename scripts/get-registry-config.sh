#!/usr/bin/env bash
set -e

# Default registry name
REGISTRY_NAME="${1:-dex-dev-registry}"

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Paths to required files
CONFIG_FILE="$PROJECT_ROOT/infrastructure/config.sh"
REGISTRY_JSON="$PROJECT_ROOT/build/registry.json"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed" >&2
    echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)" >&2
    exit 1
fi

# Check if config.sh exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found" >&2
    echo "Run ./infrastructure/deploy.sh first to generate configuration" >&2
    exit 1
fi

# Check if registry.json exists
if [ ! -f "$REGISTRY_JSON" ]; then
    echo "Error: $REGISTRY_JSON not found" >&2
    echo "Run ./scripts/package.sh first to generate registry" >&2
    exit 1
fi

# Source config to get REGISTRY_URL
source "$CONFIG_FILE"

if [ -z "$REGISTRY_URL" ]; then
    echo "Error: REGISTRY_URL not found in $CONFIG_FILE" >&2
    exit 1
fi

# Output registry block
cat << EOF
registry "$REGISTRY_NAME" {
  url = "$REGISTRY_URL"
}

EOF

# Output plugin blocks for each package
jq -r --arg registry_name "$REGISTRY_NAME" '
.packages | to_entries[] |
"plugin \"\(.key)\" {
  registry = \"\($registry_name)\"
  version  = \"\(.value.latest)\"
}
"
' "$REGISTRY_JSON"
