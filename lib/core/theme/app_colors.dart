import 'package:flutter/material.dart';

/// Nalla Pazhakam — Brand Color Palette
/// Bright, cheerful, kids-friendly colors
abstract class AppColors {
  // ── Primary brand ──────────────────────────────────────────────
  static const Color primary = Color(0xFF7C3AED);       // Purple
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color primaryDark = Color(0xFF5B21B6);

  // ── Secondary (pink / playful) ──────────────────────────────────
  static const Color secondary = Color(0xFFEC4899);     // Pink
  static const Color secondaryLight = Color(0xFFFCE7F3);
  static const Color secondaryDark = Color(0xFFBE185D);

  // ── Accent (reward / star gold) ────────────────────────────────
  static const Color accent = Color(0xFFF59E0B);        // Amber
  static const Color accentLight = Color(0xFFFEF3C7);
  static const Color accentDark = Color(0xFFD97706);

  // ── Success / habits done ──────────────────────────────────────
  static const Color success = Color(0xFF10B981);       // Emerald
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);

  // ── Danger / negative behaviour ────────────────────────────────
  static const Color danger = Color(0xFFEF4444);        // Red
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color dangerDark = Color(0xFFDC2626);

  // ── Info / weekly report ────────────────────────────────────────
  static const Color info = Color(0xFF3B82F6);          // Blue
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // ── Orange / monthly  ─────────────────────────────────────────
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFEDD5);

  // ── Neutrals ──────────────────────────────────────────────────
  static const Color background = Color(0xFFFAFAF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F3FF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF0EDE8);

  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF44403C);
  static const Color textMuted = Color(0xFF78716C);
  static const Color textDisabled = Color(0xFFA8A29E);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── Level Colors ───────────────────────────────────────────────
  static const Color levelSeedling = Color(0xFF9CA3AF);   // Grey
  static const Color levelStarLearner = Color(0xFFF59E0B); // Amber
  static const Color levelRisingStar = Color(0xFF10B981);  // Green
  static const Color levelGoldAchiever = Color(0xFFD97706); // Gold
  static const Color levelChampion = Color(0xFF7C3AED);    // Purple

  // ── Gradient presets ──────────────────────────────────────────
  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary, accent],
    stops: [0.0, 0.5, 1.0],
  );

  static const Gradient purplePinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const Gradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
  );

  static const Gradient greenBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, info],
  );

  static const Gradient cardGradients = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEDE9FE), Color(0xFFFCE7F3)],
  );
}
