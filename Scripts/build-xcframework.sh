#!/bin/bash
set -e

SCHEME_NAME="bindjs-apple"
FRAMEWORK_NAME="BindJS"
OUTPUT_DIR="$(pwd)/.build/xcframework"
XCFRAMEWORK_OUTPUT="$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"
ZIP_OUTPUT="$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework.zip"
PACKAGE_SWIFT="$(pwd)/Package.swift"
PACKAGE_BACKUP="$(pwd)/Package.swift.backup"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "=== Building XCFramework for $FRAMEWORK_NAME ==="

# Backup Package.swift
cp "$PACKAGE_SWIFT" "$PACKAGE_BACKUP"

# Restore Package.swift on exit
trap 'echo "Restoring Package.swift..."; mv "$PACKAGE_BACKUP" "$PACKAGE_SWIFT"' EXIT

# Add type: .dynamic to the library product in Package.swift
echo "Adding type: .dynamic to Package.swift..."
sed -i '' 's/targets: \["BindJS"\])/type: .dynamic, targets: ["BindJS"])/' "$PACKAGE_SWIFT"

# Build one slice: archive + copy swiftmodule + copy resource bundle.
# Args:
#   $1 archive name (e.g. ios-device)
#   $2 destination (e.g. "generic/platform=iOS")
#   $3 build-products subdir (e.g. Release-iphoneos)
build_slice() {
    local name="$1"
    local destination="$2"
    local build_dir="$3"

    local archive_path="$OUTPUT_DIR/$name"
    local derived_data="$OUTPUT_DIR/DerivedData-$name"

    echo "Building for $name ($destination)..." >&2
    xcodebuild archive \
        -scheme "$SCHEME_NAME" \
        -destination "$destination" \
        -archivePath "$archive_path" \
        -derivedDataPath "$derived_data" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO \
        -quiet >&2

    # SPM archives drop the framework at one of two install locations depending
    # on platform — find it instead of hard-coding the path.
    local framework_path
    framework_path=$(find "$archive_path.xcarchive/Products" \
        -type d -name "$FRAMEWORK_NAME.framework" -print -quit)
    if [ -z "$framework_path" ]; then
        echo "ERROR: $FRAMEWORK_NAME.framework not found in $archive_path.xcarchive" >&2
        exit 1
    fi

    local products_dir="$derived_data/Build/Intermediates.noindex/ArchiveIntermediates/$SCHEME_NAME/BuildProductsPath/$build_dir"
    local swiftmodule_src="$products_dir/$FRAMEWORK_NAME.swiftmodule"
    local bundle_src="$products_dir/${SCHEME_NAME}_${FRAMEWORK_NAME}.bundle"

    if [ ! -d "$swiftmodule_src" ]; then
        echo "ERROR: swiftmodule not found at $swiftmodule_src" >&2
        exit 1
    fi
    if [ ! -e "$bundle_src" ]; then
        echo "ERROR: resource bundle not found at $bundle_src" >&2
        exit 1
    fi

    mkdir -p "$framework_path/Modules"
    cp -R "$swiftmodule_src" "$framework_path/Modules/"
    cp -RL "$bundle_src" "$framework_path/"

    # Emit the resolved framework path on stdout for command substitution.
    echo "$framework_path"
}

IOS_DEVICE_FRAMEWORK=$(build_slice "ios-device"     "generic/platform=iOS"                          "Release-iphoneos")
IOS_SIM_FRAMEWORK=$(build_slice    "ios-simulator"  "generic/platform=iOS Simulator"                "Release-iphonesimulator")
MACOS_FRAMEWORK=$(build_slice      "macos"          "generic/platform=macOS"                        "Release")
CATALYST_FRAMEWORK=$(build_slice   "maccatalyst"    "generic/platform=macOS,variant=Mac Catalyst"   "Release-maccatalyst")

# Create XCFramework
echo "Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework "$IOS_DEVICE_FRAMEWORK" \
    -framework "$IOS_SIM_FRAMEWORK" \
    -framework "$MACOS_FRAMEWORK" \
    -framework "$CATALYST_FRAMEWORK" \
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
echo "Slices:"
ls "$XCFRAMEWORK_OUTPUT" | sed 's/^/  - /'
echo ""
echo "Upload the zip to GitHub Releases and update the binary repo's Package.swift"
