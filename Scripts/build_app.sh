#!/bin/bash
# JunkFinder'ı derler ve masaüstünde çift tıklanabilir bir .app paketi oluşturur.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Derleniyor (release)..."
swift build -c release

APP_NAME="JunkFinder.app"
BIN_PATH=".build/release/JunkFinder"
APP_DIR="$APP_NAME/Contents/MacOS"

rm -rf "$APP_NAME"
mkdir -p "$APP_DIR"
cp "$BIN_PATH" "$APP_DIR/JunkFinder"

cat > "$APP_NAME/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>JunkFinder</string>
    <key>CFBundleDisplayName</key>
    <string>JunkFinder</string>
    <key>CFBundleIdentifier</key>
    <string>local.junkfinder</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>JunkFinder</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "Hazır: $(pwd)/$APP_NAME"
echo "Finder'da çift tıklayarak açabilirsin."
