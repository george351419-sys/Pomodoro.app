#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="Pomodoro"
DISPLAY_NAME="番茄钟"
BUNDLE_ID="local.pomodoro.app"
APP_DIR="${APP_NAME}.app"
ICON_SRC="make_icon.swift"
ICON_PNG="icon_1024.png"
ICONSET="AppIcon.iconset"
ICON_ICNS="AppIcon.icns"

if [[ ! -f "${ICON_ICNS}" || "${ICON_SRC}" -nt "${ICON_ICNS}" ]]; then
    echo "==> Generating app icon..."
    swift "${ICON_SRC}" "${ICON_PNG}"
    rm -rf "${ICONSET}"
    mkdir -p "${ICONSET}"
    for spec in "16:icon_16x16" "32:icon_16x16@2x" "32:icon_32x32" \
                "64:icon_32x32@2x" "128:icon_128x128" "256:icon_128x128@2x" \
                "256:icon_256x256" "512:icon_256x256@2x" "512:icon_512x512" \
                "1024:icon_512x512@2x"; do
        sz="${spec%%:*}"
        name="${spec##*:}"
        sips -z "${sz}" "${sz}" "${ICON_PNG}" --out "${ICONSET}/${name}.png" >/dev/null
    done
    iconutil -c icns "${ICONSET}" -o "${ICON_ICNS}"
    rm -rf "${ICONSET}" "${ICON_PNG}"
fi

echo "==> Building (release)..."
swift build -c release --arch arm64

BIN_PATH="$(swift build -c release --arch arm64 --show-bin-path)/${APP_NAME}"

echo "==> Assembling ${APP_DIR}..."
rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

cp "${BIN_PATH}" "${APP_DIR}/Contents/MacOS/${APP_NAME}"
cp "${ICON_ICNS}" "${APP_DIR}/Contents/Resources/AppIcon.icns"

cat > "${APP_DIR}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${DISPLAY_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleVersion</key>
    <string>1.1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.1</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "==> Ad-hoc signing..."
codesign --force --deep --sign - "${APP_DIR}"

echo "==> Done: $(pwd)/${APP_DIR}"
