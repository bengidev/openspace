#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA_PATH="$ROOT_DIR/.vscode/DerivedData-iOS"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/OpenSpace.app"
BUNDLE_ID="io.github.bengidev.OpenSpace"

pick_simulator_udid() {
  local booted_udid
  booted_udid="$(xcrun simctl list devices available | awk -F '[()]' '/Booted/ { print $2; exit }')"
  if [[ -n "$booted_udid" ]]; then
    echo "$booted_udid"
    return 0
  fi

  local fallback_udid
  fallback_udid="$(xcrun simctl list devices available | awk -F '[()]' '/iPhone/ && /Shutdown/ { print $2; exit }')"
  if [[ -z "$fallback_udid" ]]; then
    echo "No available iPhone simulator found." >&2
    exit 1
  fi

  xcrun simctl boot "$fallback_udid" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "$fallback_udid" -b
  echo "$fallback_udid"
}

echo "Building OpenSpace for iOS Simulator..."
xcodebuild \
  -project "$ROOT_DIR/OpenSpace.xcodeproj" \
  -scheme OpenSpace \
  -configuration Debug \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build

if [[ ! -d "$APP_PATH" ]]; then
  echo "Built app not found at $APP_PATH" >&2
  exit 1
fi

SIMULATOR_UDID="$(pick_simulator_udid)"

open -a Simulator >/dev/null 2>&1 || true

echo "Installing on simulator $SIMULATOR_UDID..."
xcrun simctl install "$SIMULATOR_UDID" "$APP_PATH"

echo "Launching $BUNDLE_ID..."
exec xcrun simctl launch --console-pty --terminate-running-process "$SIMULATOR_UDID" "$BUNDLE_ID"
