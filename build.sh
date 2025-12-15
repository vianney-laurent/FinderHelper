#!/bin/bash

APP_NAME="FinderHelper"
BUILD_DIR="./build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Clean build directory
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Compile Swift code
echo "Compiling Swift code..."
swiftc FinderHelperApp.swift FinderBridge.swift \
    -o "$MACOS_DIR/$APP_NAME" \
    -target arm64-apple-macosx12.0 \
    -sdk $(xcrun --show-sdk-path) \
    -framework SwiftUI -framework AppKit -framework Foundation

if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

# Copy Info.plist
echo "Copying Info.plist..."
cp Info.plist "$CONTENTS_DIR/Info.plist"

# Convert plist to binary format (optional, best practice)
plutil -convert binary1 "$CONTENTS_DIR/Info.plist"

echo "Build successful! Application is at $APP_BUNDLE"
echo "You can run it with: open $APP_BUNDLE"
