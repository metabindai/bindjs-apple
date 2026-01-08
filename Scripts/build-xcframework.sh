#!/bin/bash
set -e

SCHEME_NAME="bindjs-apple"
FRAMEWORK_NAME="BindJS"
OUTPUT_DIR="$(pwd)/.build/xcframework"
XCFRAMEWORK_OUTPUT="$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"
ZIP_OUTPUT="$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework.zip"
DERIVED_DATA_DEVICE="$OUTPUT_DIR/DerivedData-device"
DERIVED_DATA_SIM="$OUTPUT_DIR/DerivedData-simulator"
PACKAGE_SWIFT="$(pwd)/Package.swift"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "=== Building XCFramework for $FRAMEWORK_NAME ==="

# Temporarily add type: .dynamic to Package.swift
echo "Adding type: .dynamic to Package.swift..."
sed -i '' 's/targets: \["BindJS"\])/type: .dynamic, targets: ["BindJS"])/' "$PACKAGE_SWIFT"

# Restore Package.swift on exit
trap 'echo "Restoring Package.swift..."; sed -i "" "s/type: .dynamic, targets: \[\"BindJS\"\])/targets: [\"BindJS\"])/" "$PACKAGE_SWIFT"' EXIT

# Build for iOS device
echo "Building for iOS device..."
xcodebuild archive \
    -scheme "$SCHEME_NAME" \
    -destination "generic/platform=iOS" \
    -archivePath "$OUTPUT_DIR/ios-device" \
    -derivedDataPath "$DERIVED_DATA_DEVICE" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    -quiet

# Build for iOS Simulator
echo "Building for iOS Simulator..."
xcodebuild archive \
    -scheme "$SCHEME_NAME" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$OUTPUT_DIR/ios-simulator" \
    -derivedDataPath "$DERIVED_DATA_SIM" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    -quiet

# Copy swiftmodule into frameworks
echo "Copying Swift modules..."

# iOS device
DEVICE_FRAMEWORK="$OUTPUT_DIR/ios-device.xcarchive/Products/usr/local/lib/$FRAMEWORK_NAME.framework"
DEVICE_SWIFTMODULE="$DERIVED_DATA_DEVICE/Build/Intermediates.noindex/ArchiveIntermediates/$SCHEME_NAME/BuildProductsPath/Release-iphoneos/$FRAMEWORK_NAME.swiftmodule"
mkdir -p "$DEVICE_FRAMEWORK/Modules"
cp -R "$DEVICE_SWIFTMODULE" "$DEVICE_FRAMEWORK/Modules/"

# iOS simulator
SIM_FRAMEWORK="$OUTPUT_DIR/ios-simulator.xcarchive/Products/usr/local/lib/$FRAMEWORK_NAME.framework"
SIM_SWIFTMODULE="$DERIVED_DATA_SIM/Build/Intermediates.noindex/ArchiveIntermediates/$SCHEME_NAME/BuildProductsPath/Release-iphonesimulator/$FRAMEWORK_NAME.swiftmodule"
mkdir -p "$SIM_FRAMEWORK/Modules"
cp -R "$SIM_SWIFTMODULE" "$SIM_FRAMEWORK/Modules/"

# Create XCFramework
echo "Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework "$DEVICE_FRAMEWORK" \
    -framework "$SIM_FRAMEWORK" \
    -output "$XCFRAMEWORK_OUTPUT"

# Create zip
echo "Creating zip..."
cd "$OUTPUT_DIR"
zip -r -q "$FRAMEWORK_NAME.xcframework.zip" "$FRAMEWORK_NAME.xcframework"

# Calculate checksum
CHECKSUM=$(swift package compute-checksum "$ZIP_OUTPUT")

echo ""
echo "=== Done ==="
echo "Zip: $ZIP_OUTPUT"
echo "Checksum: $CHECKSUM"
echo ""
echo "Upload the zip to GitHub Releases and update the binary repo's Package.swift"
