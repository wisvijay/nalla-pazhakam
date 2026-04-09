import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/database/database_service.dart';
import 'core/providers/auth_provider.dart';
import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Init Firebase (if configured) ──────────────────────────
  bool firebaseReady = false;
  if (kFirebaseConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseReady = true;
    } catch (e) {
      debugPrint('⚠️  Firebase init failed: $e');
    }
  }

  // ── 2. Init Hive (IndexedDB on web, file system on mobile) ────
  await Hive.initFlutter();

  // ── 3. Register adapters, open boxes, seed habits ─────────────
  await DatabaseService.init();

  // ── 4. Lock to portrait on mobile ─────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── 5. Status bar style ───────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ── 6. Run app ────────────────────────────────────────────────
  runApp(
    ProviderScope(
      overrides: [
        firebaseReadyProvider.overrideWith((ref) => firebaseReady),
      ],
      child: const NallaPazhakamApp(),
    ),
  );
}
