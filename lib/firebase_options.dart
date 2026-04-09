// ─────────────────────────────────────────────────────────────────────────────
// SETUP REQUIRED — replace this file with your real Firebase config:
//
//   1. Go to  https://console.firebase.google.com  and create a project.
//   2. Enable  Authentication → Email/Password  and  Firestore Database.
//   3. Install the FlutterFire CLI:
//        dart pub global activate flutterfire_cli
//   4. From inside the nalla_pazhakam/ folder run:
//        flutterfire configure --project=YOUR_PROJECT_ID
//      That rewrites this file with real values automatically.
//
//   Until you do this the Groups / Leaderboard feature will be disabled,
//   but the rest of the app (local habit tracking) works fine.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Set to true after running `flutterfire configure` and filling in real values.
const bool kFirebaseConfigured = false;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  // ── PLACEHOLDERS — overwritten by `flutterfire configure` ─────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_WEB_API_KEY',
    appId: 'REPLACE_WITH_YOUR_WEB_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    authDomain: 'REPLACE_WITH_YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'REPLACE_WITH_YOUR_PROJECT_ID.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_ANDROID_API_KEY',
    appId: 'REPLACE_WITH_YOUR_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_YOUR_PROJECT_ID.firebasestorage.app',
  );
}
