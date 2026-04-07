#!/usr/bin/env bash
# Build the go4-fashion skill bundle as a ZIP for upload to Claude Cowork.
#
# Usage:  ./dist/build.sh
# Output: dist/go4-fashion.zip
#
# Run from the repo root or from inside dist/. The script normalizes its CWD.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SKILL_DIR="go4-fashion"
ZIP_NAME="go4-fashion.zip"

if [[ ! -d "$SKILL_DIR" ]]; then
  echo "ERROR: $SCRIPT_DIR/$SKILL_DIR does not exist" >&2
  exit 1
fi

if [[ ! -f "$SKILL_DIR/SKILL.md" ]]; then
  echo "ERROR: $SCRIPT_DIR/$SKILL_DIR/SKILL.md is missing — every skill needs a SKILL.md at its root" >&2
  exit 1
fi

# Remove the previous ZIP so the new one replaces it cleanly.
rm -f "$ZIP_NAME"

# Exclude macOS metadata and any stray hidden files. -r recursive, -q quiet.
zip -rq "$ZIP_NAME" "$SKILL_DIR" \
  -x "*.DS_Store" "*/.DS_Store" "*/__MACOSX/*"

ZIP_SIZE=$(du -h "$ZIP_NAME" | awk '{print $1}')
FILE_COUNT=$(unzip -l "$ZIP_NAME" | tail -1 | awk '{print $2}')

echo "Built $SCRIPT_DIR/$ZIP_NAME ($ZIP_SIZE, $FILE_COUNT files)"
echo ""
echo "Upload this ZIP in Claude Desktop:"
echo "  Customize -> Skills -> + Create skill -> Upload a skill"
