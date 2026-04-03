#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  RAMMonitor — build script
#  Usage:  bash build.sh          (Debug, launches the app)
#          bash build.sh release  (Release, produces RAMMonitor.app)
# ─────────────────────────────────────────────────────────────

set -euo pipefail

CONFIG="${1:-debug}"
SCHEME="RAMMonitor"
PROJECT="RAMMonitor.xcodeproj"
OUT="build"

echo "→ Building ($CONFIG)…"

xcodebuild \
  -project "$PROJECT" \
  -scheme  "$SCHEME"  \
  -configuration "$(echo "$CONFIG" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')" \
  -derivedDataPath "$OUT"     \
  CODE_SIGN_IDENTITY="-"      \
  CODE_SIGNING_REQUIRED=NO    \
  build

APP=$(find "$OUT" -name "RAMMonitor.app" | head -1)
echo ""
echo "✓ Built: $APP"

if [[ "$CONFIG" == "debug" ]]; then
  echo "→ Launching…"
  open "$APP"
fi
