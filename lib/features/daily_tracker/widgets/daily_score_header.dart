import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/score_calculator.dart';

/// Animated circular progress ring showing today's completion %.
/// Turns green and shows ⭐ when the star threshold is reached.
class DailyScoreHeader extends StatelessWidget {
  final double score;          // 0.0 – 1.0
  final int completedCount;
  final int totalCount;
  final int deductionCount;

  const DailyScoreHeader({
    super.key,
    required this.score,
    required this.completedCount,
    required this.totalCount,
    required this.deductionCount,
  });

  @override
  Widget build(BuildContext context) {
    final earnedStar = ScoreCalculator.earnedStar(score);
    final percent = (score * 100).round();

    final ringColor = earnedStar
        ? AppColors.success
        : score > 0.4
            ? AppColors.accent
            : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppColors.purplePinkGradient,
      ),
      child: Row(
        children: [
          // ── Circular ring ──────────────────────────────────
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background track
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 8,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                // Animated fill
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: score),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, __) => CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        color: ringColor,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                // Centre text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: earnedStar
                      ? const Text('⭐',
                          key: ValueKey('star'),
                          style: TextStyle(fontSize: 36))
                      : Text(
                          '$percent%',
                          key: ValueKey(percent),
                          style: AppTextStyles.h3
                              .copyWith(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // ── Stats ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    earnedStar ? '⭐ Star Earned!' : _motivationalText(percent),
                    key: ValueKey(earnedStar),
                    style: AppTextStyles.h4.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$completedCount of $totalCount habits done',
                  style: AppTextStyles.body
                      .copyWith(color: Colors.white70),
                ),
                if (deductionCount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.remove_circle_outline,
                          color: Colors.white60, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$deductionCount behaviour mark${deductionCount > 1 ? 's' : ''}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ],
                if (!earnedStar && totalCount > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      '${_habitsNeededForStar()} more for ⭐',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _motivationalText(int percent) {
    if (percent == 0) return 'Let\'s start! 💪';
    if (percent < 30) return 'Good start! 🌱';
    if (percent < 60) return 'Keep going! 🔥';
    if (percent < AppConstants.starThreshold * 100) return 'Almost there! 🚀';
    return 'Great job! 🎉';
  }

  int _habitsNeededForStar() {
    if (totalCount == 0) return 0;
    final needed = (AppConstants.starThreshold * totalCount).ceil();
    return (needed - completedCount).clamp(0, totalCount);
  }
}
