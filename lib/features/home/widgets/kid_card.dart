import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/score_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/kid_model.dart';
import '../../../shared/widgets/kid_avatar.dart';
import '../../../shared/widgets/level_badge.dart';

/// Card shown in the home screen kids list.
class KidCard extends ConsumerWidget {
  final KidModel kid;

  const KidCard({super.key, required this.kid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreService = ref.watch(scoreServiceProvider);
    final todayScore = scoreService.getDailyScore(kid.id, DateTime.now());
    final todayPercent = (todayScore * 100).round();
    final earnedStar = scoreService.didEarnStarForDay(kid.id, DateTime.now());
    final weeklyStats =
        scoreService.getWeeklyStats(kid.id, DateTime.now());

    return GestureDetector(
      onTap: () => context.push('/kids/${kid.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ─────────────────────────────────────────
            Stack(
              children: [
                KidAvatar(
                  name: kid.name,
                  photoBase64: kid.photoBase64,
                  size: 60,
                ),
                if (earnedStar)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('⭐',
                          style: TextStyle(fontSize: 14)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // ── Info ───────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(kid.name,
                            style: AppTextStyles.h4,
                            overflow: TextOverflow.ellipsis),
                      ),
                      LevelBadge(level: kid.currentLevel, compact: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NallaDateUtils.formatAge(kid.dob),
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),

                  // ── Progress bar ──────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: todayScore,
                            backgroundColor: AppColors.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              todayScore >= AppConstants.starThreshold
                                  ? AppColors.success
                                  : AppColors.accent,
                            ),
                            minHeight: 7,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$todayPercent%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: todayScore >= AppConstants.starThreshold
                              ? AppColors.success
                              : AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Today  •  ${weeklyStats.starsEarned} ⭐ this week',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
