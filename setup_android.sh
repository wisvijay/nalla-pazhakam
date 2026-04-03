#!/bin/bash
# Run this ONCE from inside the nalla_pazhakam folder to add Android support.
# Usage:  bash setup_android.sh

set -e

echo "🤖 Adding Android platform..."
flutter create --platforms=android .

MANIFEST="android/app/src/main/AndroidManifest.xml"

echo "🔐 Adding permissions to AndroidManifest.xml..."

# Insert permissions before the <application> tag
sed -i 's|<application|<!-- Image Picker permissions -->\
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />\
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"\
        android:maxSdkVersion="32" />\
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"\
        android:maxSdkVersion="28" />\
    <application|' "$MANIFEST"

echo "✅ Done! Android platform ready."
echo ""
echo "Next steps:"
echo "  git add android/ pubspec.yaml pubspec.lock .github/"
echo "  git commit -m 'Add Android platform support'"
echo "  git push"
