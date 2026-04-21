#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ROOT_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
CONFIG_PATH="$ROOT_DIR/.swiftformat"
CACHE_PATH="$ROOT_DIR/.build/swiftformat.cache"
SWIFTFORMAT_BIN="${SWIFTFORMAT_BIN:-}"

if [ -z "$SWIFTFORMAT_BIN" ]; then
  SWIFTFORMAT_BIN="$(command -v swiftformat || true)"
fi

if [ -z "$SWIFTFORMAT_BIN" ]; then
  echo "warning: SwiftFormat is not installed. Install it or set SWIFTFORMAT_BIN to enable automatic formatting."
  exit 0
fi

if [ ! -f "$CONFIG_PATH" ]; then
  echo "warning: Missing $CONFIG_PATH. Skipping SwiftFormat."
  exit 0
fi

if [ "$#" -eq 0 ]; then
  set -- "$ROOT_DIR/OpenSpace" "$ROOT_DIR/OpenSpaceTests" "$ROOT_DIR/OpenSpaceUITests"
fi

"$SWIFTFORMAT_BIN" "$@" --config "$CONFIG_PATH" --cache "$CACHE_PATH" --quiet
