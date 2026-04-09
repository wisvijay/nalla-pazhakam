#!/bin/bash
# Run this ONCE from inside the nalla_pazhakam folder to add Android support.
# Usage:  bash setup_android.sh

set -e

echo "🤖 Adding Android platform..."
flutter create --platforms=android .

MANIFEST="android/app/src/main/AndroidManifest.xml"

echo "📝 Setting app label to 'Good Habits'..."
sed -i 's|android:label="[^"]*"|android:label="Good Habits"|g' "$MANIFEST"

echo "🔐 Adding permissions to AndroidManifest.xml..."
sed -i 's|<application|<!-- Image Picker permissions -->\
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />\
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"\
        android:maxSdkVersion="32" />\
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"\
        android:maxSdkVersion="28" />\
    <application|' "$MANIFEST"

echo "🎨 Copying app icons..."
RES="android/app/src/main/res"
cp assets/android_icons/mipmap-mdpi_ic_launcher.png     "$RES/mipmap-mdpi/ic_launcher.png"
cp assets/android_icons/mipmap-hdpi_ic_launcher.png     "$RES/mipmap-hdpi/ic_launcher.png"
cp assets/android_icons/mipmap-xhdpi_ic_launcher.png    "$RES/mipmap-xhdpi/ic_launcher.png"
cp assets/android_icons/mipmap-xxhdpi_ic_launcher.png   "$RES/mipmap-xxhdpi/ic_launcher.png"
cp assets/android_icons/mipmap-xxxhdpi_ic_launcher.png  "$RES/mipmap-xxxhdpi/ic_launcher.png"

echo "✅ Done! Android platform ready."
echo ""
echo "Next steps:"
echo "  git add android/ pubspec.yaml pubspec.lock .github/ assets/"
echo "  git commit -m 'Add Android platform with Good Habits branding'"
echo "  git push"
