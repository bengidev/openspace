#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA_PATH="$ROOT_DIR/.vscode/DerivedData-iPadAir13M4"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/OpenSpace.app"
BUNDLE_ID="io.github.bengidev.OpenSpace"
SIMULATOR_NAME="iPad Air 13-inch (M4)"
SIMULATOR_UDID="0A9062C9-DE70-406A-8245-6368250E9BF1"
PID_FILE="$ROOT_DIR/.vscode/ipad-air-13-m4-sim-debug.pid"
WAIT_FOR_DEBUGGER=0
BUILD_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wait-for-debugger)
      WAIT_FOR_DEBUGGER=1
      ;;
    --build-only)
      BUILD_ONLY=1
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
  shift
done

resolve_simulator_udid() {
  if xcrun simctl list devices available | grep -Fq "$SIMULATOR_UDID"; then
    echo "$SIMULATOR_UDID"
    return 0
  fi

  local resolved_udid
  resolved_udid="$(xcrun simctl list devices available | awk -F '[()]' -v name="$SIMULATOR_NAME" '$0 ~ name { print $2; exit }')"
  if [[ -z "$resolved_udid" ]]; then
    echo "No available $SIMULATOR_NAME simulator found." >&2
    exit 1
  fi

  echo "$resolved_udid"
}

boot_simulator() {
  local udid="$1"

  if ! xcrun simctl list devices available | grep -F "$udid" | grep -Fq "Booted"; then
    xcrun simctl boot "$udid" >/dev/null 2>&1 || true
  fi

  xcrun simctl bootstatus "$udid" -b
}

SIMULATOR_UDID="$(resolve_simulator_udid)"
DESTINATION="id=$SIMULATOR_UDID"

echo "Building OpenSpace for $SIMULATOR_NAME ($SIMULATOR_UDID)..."
xcodebuild \
  -project "$ROOT_DIR/OpenSpace.xcodeproj" \
  -scheme OpenSpace \
  -configuration Debug \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build

if [[ "$BUILD_ONLY" -eq 1 ]]; then
  exit 0
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "Built app not found at $APP_PATH" >&2
  exit 1
fi

open -a Simulator >/dev/null 2>&1 || true
boot_simulator "$SIMULATOR_UDID"

echo "Installing on $SIMULATOR_NAME ($SIMULATOR_UDID)..."
xcrun simctl install "$SIMULATOR_UDID" "$APP_PATH"

echo "Launching $BUNDLE_ID on $SIMULATOR_NAME..."
if [[ "$WAIT_FOR_DEBUGGER" -eq 1 ]]; then
  LAUNCH_OUTPUT="$(xcrun simctl launch --wait-for-debugger --terminate-running-process "$SIMULATOR_UDID" "$BUNDLE_ID")"
  printf '%s\n' "$LAUNCH_OUTPUT" | awk -F ': ' 'NF > 1 { print $NF }' > "$PID_FILE"
  echo "$LAUNCH_OUTPUT"
  echo "Debugger attach is ready. If VSCode asks for a process, pick OpenSpace or the PID in $PID_FILE."
  exit 0
fi

exec xcrun simctl launch --console-pty --terminate-running-process "$SIMULATOR_UDID" "$BUNDLE_ID"
