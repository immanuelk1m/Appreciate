#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

cp "$ROOT/local-checks/menu-bar-regression.swift" "$TEMP_DIR/main.swift"
swiftc \
  -o "$TEMP_DIR/menu-bar-regression" \
  -target arm64-apple-macosx14.0 \
  -sdk "$(xcrun --show-sdk-path)" \
  -framework Cocoa \
  -framework SwiftUI \
  "$ROOT/macos/Sources/TimerManager.swift" \
  "$ROOT/macos/Sources/AppDelegate.swift" \
  "$TEMP_DIR/main.swift"
"$TEMP_DIR/menu-bar-regression"
