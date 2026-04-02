import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system — Nunito via google_fonts, kids-friendly bold weights
abstract class AppTextStyles {
  // ── Display (big celebrations, level-up screens) ───────────────
  static TextStyle get display => GoogleFonts.nunito(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        height: 1.1,
        letterSpacing: -0.5,
      );

  // ── Headings ───────────────────────────────────────────────────
  static TextStyle get h1 => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get h2 => GoogleFonts.nunito(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  static TextStyle get h3 => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h4 => GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  // ── Body ────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        height: 1.4,
      );

  // ── Labels & captions ──────────────────────────────────────────
  static TextStyle get label => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.2,
      );

  static TextStyle get labelSmall => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      );

  // ── Button ─────────────────────────────────────────────────────
  static TextStyle get button => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      );

  static TextStyle get buttonSmall => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      );

  // ── Score / number callout ─────────────────────────────────────
  static TextStyle get scoreXL => GoogleFonts.nunito(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
        height: 1.0,
      );

  static TextStyle get scoreLG => GoogleFonts.nunito(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
        height: 1.0,
      );
}
