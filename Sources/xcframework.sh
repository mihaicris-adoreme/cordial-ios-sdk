#!/bin/sh

# ----------------------------------
# BUILD PLATFORM SPECIFIC FRAMEWORKS
# ----------------------------------

# iOS devices
xcodebuild archive \
    -project ./../Projects/Frameworks/CordialSDK/CordialSDK.xcodeproj \
    -scheme CordialSDK \
    -archivePath "./build/ios.xcarchive" \
    -destination "generic/platform=iOS" \
    SKIP_INSTALL=NO
# iOS simulator
xcodebuild archive \
    -project ./../Projects/Frameworks/CordialSDK/CordialSDK.xcodeproj \
    -scheme CordialSDK \
    -archivePath "./build/ios_sim.xcarchive" \
    -destination "generic/platform=iOS Simulator" \
    SKIP_INSTALL=NO
# macOS
xcodebuild archive \
    -project ./../Projects/Frameworks/CordialSDK/CordialSDK.xcodeproj \
    -scheme CordialSDK \
    -archivePath "./build/macos.xcarchive" \
    -destination "generic/platform=macOS,variant=Mac Catalyst" \
    SKIP_INSTALL=NO

# -------------------
# PACKAGE XCFRAMEWORK
# -------------------

# Delete old framework
rm -rf CordialSDK.xcframework

# Create new framework
xcodebuild -create-xcframework \
    -framework "./build/ios.xcarchive/Products/Library/Frameworks/CordialSDK.framework" \
    -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/CordialSDK.framework" \
    -framework "./build/macos.xcarchive/Products/Library/Frameworks/CordialSDK.framework" \
    -output "./CordialSDK.xcframework"

# Delete build folder
rm -rf build
