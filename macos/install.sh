#!/bin/zsh
set -euo pipefail
repo_root="${0:A:h:h}"
app_path="${1:-/Applications/Harvey.app}"
mkdir -p "$app_path/Contents/MacOS" "$app_path/Contents/Resources"
swiftc "$repo_root/macos/Harvey.swift" -o "$app_path/Contents/MacOS/Harvey" -framework Cocoa -framework WebKit
cp "$repo_root/macos/Info.plist" "$app_path/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :HarveyWorkspaceRoot string $repo_root" "$app_path/Contents/Info.plist"
cp "$repo_root/assets/Harvey.icns" "$app_path/Contents/Resources/Harvey.icns"
codesign --force --deep --sign - "$app_path"
echo "Installed $app_path"
