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

# Fix up the macOS slice: it is a *versioned* framework (Versions/A + a Current
# symlink), but build_slice copies Modules + the resource bundle to the framework
# root — fine for flat (iOS) frameworks, illegal for versioned ones. codesign
# then rejects "unsealed contents present in the root directory of an embedded
# framework", breaking every macOS app that signs under a hardened runtime.
# Relocate those into Versions/A with top-level symlinks, and ad-hoc-sign the
# nested (executable-less) resource bundle so downstream apps can seal it.
echo "Fixing up macOS versioned framework structure..."
(
    cd "$MACOS_FRAMEWORK"
    for item in "Modules" "${SCHEME_NAME}_${FRAMEWORK_NAME}.bundle"; do
        if [ -e "$item" ] && [ ! -L "$item" ]; then
            mv "$item" "Versions/A/$item"
            ln -s "Versions/Current/$item" "$item"
        fi
    done
    codesign --force --sign - "Versions/A/${SCHEME_NAME}_${FRAMEWORK_NAME}.bundle"
)

# Create XCFramework
echo "Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework "$IOS_DEVICE_FRAMEWORK" \
    -framework "$IOS_SIM_FRAMEWORK" \
    -framework "$MACOS_FRAMEWORK" \
    -framework "$CATALYST_FRAMEWORK" \
    -output "$XCFRAMEWORK_OUTPUT"

# Create zip
# NOTE: use ditto, not `zip` — `zip` (without -y) dereferences symlinks, which
# flattens the macOS framework's Versions/Current + top-level symlinks into real
# copies. That produces an unsignable framework (codesign rejects it under a
# hardened runtime), breaking every macOS app that embeds the binary. ditto
# preserves symlinks and extended attributes.
echo "Creating zip..."
cd "$OUTPUT_DIR"
ditto -c -k --keepParent "$FRAMEWORK_NAME.xcframework" "$FRAMEWORK_NAME.xcframework.zip"

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
