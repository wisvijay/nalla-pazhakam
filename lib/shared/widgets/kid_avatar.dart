import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Displays a kid's photo (from base64) or a colourful emoji fallback.
class KidAvatar extends StatelessWidget {
  final String? photoBase64;
  final String name;
  final double size;
  final List<Color>? gradientColors;

  const KidAvatar({
    super.key,
    required this.name,
    this.photoBase64,
    this.size = 56,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: photoBase64 == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ?? _colorsForName(name),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: photoBase64 != null
            ? Image.memory(
                base64Decode(photoBase64!),
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Center(
      child: Text(
        _emojiForName(name),
        style: TextStyle(fontSize: size * 0.45),
      ),
    );
  }

  /// Deterministic gradient based on the first letter of the name.
  static List<Color> _colorsForName(String name) {
    final gradients = [
      [AppColors.primary, AppColors.secondary],
      [AppColors.success, AppColors.info],
      [AppColors.accent, AppColors.danger],
      [AppColors.orange, AppColors.secondary],
      [AppColors.info, AppColors.primary],
    ];
    final idx = name.isEmpty ? 0 : name.codeUnitAt(0) % gradients.length;
    return gradients[idx];
  }

  static String _emojiForName(String name) {
    const emojis = ['😊', '🌟', '🎈', '🦋', '🌸', '🐣', '🌈', '🦄'];
    if (name.isEmpty) return emojis[0];
    return emojis[name.codeUnitAt(0) % emojis.length];
  }
}
