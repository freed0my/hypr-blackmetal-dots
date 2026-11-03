#!/usr/bin/env bash
# Builds a single self-contained rin-hypr-dots.sh (install.sh + dots/ archive).
# Handy for sharing on Discord or attaching to a GitHub Release.
set -euo pipefail
cd "$(dirname "$0")"
OUT="$PWD/rin-hypr-dots.sh"
sed 's/^BUNDLED=0 /BUNDLED=1 /' install.sh > "$OUT"
echo "__PAYLOAD__" >> "$OUT"
tar --owner=0 --group=0 -cf - dots | xz -9e -T0 >> "$OUT"
chmod +x "$OUT"
echo "Done: $OUT ($(du -h "$OUT" | cut -f1))"
