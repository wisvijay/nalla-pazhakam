import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/database/database_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Init Hive (IndexedDB on web, file on mobile) ───────────
  await Hive.initFlutter();

  // ── 2. Register adapters, open boxes, seed habits ─────────────
  await DatabaseService.init();

  // ── 3. Lock to portrait on mobile (no-op on web) ──────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── 4. Status bar style ───────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ── 5. Run app ────────────────────────────────────────────────
  runApp(
    const ProviderScope(
      child: NallaPazhakamApp(),
    ),
  );
}
