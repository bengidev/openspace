#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ROOT_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
CONFIG_PATH="$ROOT_DIR/.swiftformat"
CACHE_PATH="$ROOT_DIR/.build/swiftformat.cache"
SWIFTFORMAT_BIN="${SWIFTFORMAT_BIN:-}"
SWIFTFORMAT_MODE="${SWIFTFORMAT_MODE:-format}"
SWIFTFORMAT_REQUIRED="${SWIFTFORMAT_REQUIRED:-0}"

case "$SWIFTFORMAT_MODE" in
  format | lint) ;;
  *)
    echo "error: Unsupported SWIFTFORMAT_MODE '$SWIFTFORMAT_MODE'. Use 'format' or 'lint'."
    exit 2
    ;;
esac

if [ -z "$SWIFTFORMAT_BIN" ]; then
  SWIFTFORMAT_BIN="$(command -v swiftformat || true)"
fi

if [ -z "$SWIFTFORMAT_BIN" ]; then
  echo "warning: SwiftFormat is not installed. Install it with 'brew install swiftformat' or set SWIFTFORMAT_BIN."
  if [ "$SWIFTFORMAT_REQUIRED" = "1" ]; then
    exit 1
  else
    exit 0
  fi
fi

if [ ! -f "$CONFIG_PATH" ]; then
  echo "note: Missing $CONFIG_PATH. Skipping SwiftFormat."
  exit 0
fi

if [ "$#" -eq 0 ]; then
  set -- "$ROOT_DIR/OpenSpace" "$ROOT_DIR/OpenSpaceTests" "$ROOT_DIR/OpenSpaceUITests"
fi

mkdir -p "$(dirname "$CACHE_PATH")"

if [ "$SWIFTFORMAT_MODE" = "lint" ]; then
  "$SWIFTFORMAT_BIN" "$@" --config "$CONFIG_PATH" --cache "$CACHE_PATH" --lint
else
  "$SWIFTFORMAT_BIN" "$@" --config "$CONFIG_PATH" --cache "$CACHE_PATH" --quiet
fi
