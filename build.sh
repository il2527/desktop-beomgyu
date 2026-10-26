#!/bin/zsh
set -euo pipefail
cd "${0:A:h}"
APP="build/Beomgyu Desktop.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc -module-cache-path /private/tmp/beomgyu-swift-cache main.swift -o "$APP/Contents/MacOS/BeomgyuDesktop" -framework AppKit -framework UniformTypeIdentifiers
cp beomgyu-standing.png beomgyu-walk-right.png beomgyu-celebrate.png beomgyu-run-0.png beomgyu-run-1.png "$APP/Contents/Resources/"
mkdir -p "$APP/Contents/Resources/hug-frames"
cp frame-*.png frames.json "$APP/Contents/Resources/hug-frames/"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>BeomgyuDesktop</string>
<key>CFBundleIdentifier</key><string>local.desktop.beomgyu</string>
<key>CFBundleName</key><string>Beomgyu Desktop</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$APP"
