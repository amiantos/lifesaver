#!/bin/zsh
set -e

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

cd "$(dirname "$0")"

echo "==> Building LifeSaverCore"
xcodebuild -project "Life Saver.xcodeproj" -scheme LifeSaverCore -configuration Debug build -quiet

echo "==> Building Life Saver Extension"
xcodebuild -project "Life Saver.xcodeproj" -scheme "Life Saver Extension" -configuration Debug build -quiet

echo "==> Building Life Saver (host)"
xcodebuild -project "Life Saver.xcodeproj" -scheme "Life Saver" -configuration Debug build -quiet

DD="$(xcodebuild -project "Life Saver.xcodeproj" -scheme "Life Saver" -configuration Debug -showBuildSettings 2>/dev/null | awk -F' = ' '$1 ~ /^ *BUILT_PRODUCTS_DIR/ {print $2; exit}')"
SRC="$DD/Life Saver.app"
DST=/Applications/Life\ Saver.app

if [[ ! -d "$SRC" ]]; then
    echo "build product not found at $SRC" >&2
    exit 1
fi

echo "==> Installing to /Applications"
rm -rf "$DST"
cp -R "$SRC" /Applications/
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f -R "$DST" >/dev/null 2>&1 || true

echo "==> Launching host to refresh LS index"
open "$DST"
sleep 2
osascript -e 'tell application "Life Saver" to quit' 2>/dev/null || true
sleep 1

echo "==> pluginkit state"
pluginkit -m -v -p com.apple.screensaver | grep -iE "amiantos|life" || echo "  (not registered)"
