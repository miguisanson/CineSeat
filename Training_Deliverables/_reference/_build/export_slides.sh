#!/bin/bash
# Export every deck to PNG via Keynote. These PNGs ARE the video's frames, so the
# videos can never disagree with the decks.
set -e
BASE="/Users/miguelsanson/Desktop/Github_Repos/IOS_Development/CineSeat/Training_Deliverables"
OUT="$BASE/_reference/slides_png"
rm -rf "$OUT"; mkdir -p "$OUT"
for f in "$BASE"/1_PPTS/*.pptx; do
  n=$(basename "$f" .pptx)
  mkdir -p "$OUT/$n"
  osascript <<OSA >/dev/null
tell application "Keynote"
  set d to open POSIX file "$f"
  export d to POSIX file "$OUT/$n" as slide images with properties {image format:PNG, skipped slides:false}
  close d saving no
end tell
OSA
  echo "  $n: $(ls "$OUT/$n" | wc -l | tr -d ' ') slides"
done
