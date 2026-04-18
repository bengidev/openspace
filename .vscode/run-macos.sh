#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA_PATH="$ROOT_DIR/.vscode/DerivedData"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug/OpenSpace.app"
BUNDLE_ID="io.github.bengidev.OpenSpace"

echo "Building OpenSpace for macOS..."
xcodebuild \
  -project "$ROOT_DIR/OpenSpace.xcodeproj" \
  -scheme OpenSpace \
  -configuration Debug \
  -destination "platform=macOS" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build

if [[ ! -d "$APP_PATH" ]]; then
  echo "Built app not found at $APP_PATH" >&2
  exit 1
fi

echo "Launching $BUNDLE_ID..."
osascript -e "tell application id \"$BUNDLE_ID\" to quit" >/dev/null 2>&1 || true
open -n "$APP_PATH"
