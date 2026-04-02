import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Coloured badge showing a kid's current level (1–5).
class LevelBadge extends StatelessWidget {
  final int level;
  final bool compact;

  const LevelBadge({super.key, required this.level, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final clampedLevel = level.clamp(1, 5);
    final color = _colorForLevel(clampedLevel);
    final emoji = AppConstants.levelEmojis[clampedLevel - 1];
    final name = AppConstants.levelNames[clampedLevel - 1];

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              'Lv $clampedLevel',
              style: AppTextStyles.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            name,
            style: AppTextStyles.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  static Color _colorForLevel(int level) {
    switch (level) {
      case 1:
        return AppColors.levelSeedling;
      case 2:
        return AppColors.levelStarLearner;
      case 3:
        return AppColors.levelRisingStar;
      case 4:
        return AppColors.levelGoldAchiever;
      case 5:
        return AppColors.levelChampion;
      default:
        return AppColors.levelSeedling;
    }
  }
}
