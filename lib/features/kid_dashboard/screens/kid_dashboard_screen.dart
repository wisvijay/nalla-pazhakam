import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/score_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/repositories/kid_repository.dart';
import '../../../shared/widgets/kid_avatar.dart';
import '../../../shared/widgets/level_badge.dart';

class KidDashboardScreen extends ConsumerWidget {
  final String kidId;

  const KidDashboardScreen({super.key, required this.kidId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kid = ref.watch(kidRepositoryProvider).getById(kidId);
    if (kid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('Child not found')),
      );
    }

    final scoreService = ref.watch(scoreServiceProvider);
    final today = DateTime.now();
    final todayScore = scoreService.getDailyScore(kidId, today);
    final todayDeductions = scoreService.getDailyDeductions(kidId, today);
    final earnedStar = scoreService.didEarnStarForDay(kidId, today);
    final weeklyStats = scoreService.getWeeklyStats(kidId, today);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                tooltip: 'Edit profile',
                onPressed: () => context.push(
                  AppRoutes.editKid.replaceFirst(':kidId', kidId),
                ),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                    gradient: AppColors.purplePinkGradient),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 44),
                    // Avatar with star overlay
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        KidAvatar(
                            name: kid.name,
                            photoBase64: kid.photoBase64,
                            size: 76),
                        if (earnedStar)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Text('⭐',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(kid.name,
                        style: AppTextStyles.h2
                            .copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(NallaDateUtils.formatAge(kid.dob),
                        style: AppTextStyles.body
                            .copyWith(color: Colors.white70)),
                    const SizedBox(height: 6),
                    LevelBadge(level: kid.currentLevel),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding:
                const EdgeInsets.all(AppConstants.defaultPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Today's progress card ──────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Today\'s Habits',
                              style: AppTextStyles.h4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: earnedStar
                                  ? AppColors.successLight
                                  : AppColors.accentLight,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              earnedStar
                                  ? '⭐ Star earned!'
                                  : '${(todayScore * 100).round()}% done',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: earnedStar
                                    ? AppColors.success
                                    : AppColors.accentDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: todayScore,
                          backgroundColor: AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            earnedStar
                                ? AppColors.success
                                : AppColors.accent,
                          ),
                          minHeight: 12,
                        ),
                      ),
                      if (todayDeductions > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.remove_circle_outline,
                                color: AppColors.danger, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$todayDeductions behaviour mark${todayDeductions > 1 ? 's' : ''} today',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.danger),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(
                            '${AppRoutes.dailyTracker.replaceFirst(':kidId', kidId)}?date=${NallaDateUtils.dayKey(today)}',
                          ),
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: const Text('Mark Today\'s Habits'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── This week ──────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('This Week', style: AppTextStyles.h4),
                      const SizedBox(height: 14),
                      _WeekStarRow(
                          stats: weeklyStats, weekStart: today),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _StatChip(
                            label: 'Stars',
                            value: '${weeklyStats.starsEarned} ⭐',
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            label: 'Avg',
                            value: weeklyStats.percentLabel,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 10),
                          _StatChip(
                            label: 'Deductions',
                            value:
                                '${weeklyStats.totalDeductions}',
                            color: AppColors.danger,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () => context.push(
                          AppRoutes.weeklyReport
                              .replaceFirst(':kidId', kidId),
                        ),
                        icon: const Icon(Icons.star_outline_rounded),
                        label: const Text('View Weekly Report'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Monthly quick-access ───────────────────────
                _SectionCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.emoji_events_rounded,
                          color: AppColors.primary),
                    ),
                    title: Text('Monthly Report',
                        style: AppTextStyles.h4),
                    subtitle: Text(
                      NallaDateUtils.formatMonthYear(today),
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(
                      AppRoutes.monthlyReport
                          .replaceFirst(':kidId', kidId),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Favourite things ───────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Favourite Things',
                          style: AppTextStyles.h4),
                      const SizedBox(height: 12),
                      _FavRow(icon: '🍽️', label: 'Food', value: kid.favFood),
                      _FavRow(
                          icon: '🍪',
                          label: 'Snacks',
                          value: kid.favSnacks),
                      _FavRow(
                          icon: '🍎',
                          label: 'Fruits',
                          value: kid.favFruits),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ───────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: child,
      );
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(value,
                  style: AppTextStyles.h4.copyWith(color: color)),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
        ),
      );
}

class _FavRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _FavRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text('$label: ',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.textMuted)),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                style: AppTextStyles.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}

class _WeekStarRow extends StatelessWidget {
  final WeeklyStats stats;
  final DateTime weekStart;
  const _WeekStarRow({required this.stats, required this.weekStart});

  @override
  Widget build(BuildContext context) {
    final days = NallaDateUtils.daysInWeek(weekStart);
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final day = days[i];
        final isPast = !day.isAfter(today);
        final hasScore = i < stats.dailyScores.length;
        final earned =
            hasScore && ScoreCalculatorHelper.earnedStar(stats.dailyScores[i]);

        return Column(
          children: [
            Text(
              isPast && earned
                  ? '⭐'
                  : isPast
                      ? '○'
                      : '·',
              style: TextStyle(
                fontSize: isPast && earned ? 20 : 18,
                color: isPast ? AppColors.textPrimary : AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: 4),
            Text(dayLabels[i],
                style: AppTextStyles.caption.copyWith(
                  color: NallaDateUtils.isToday(day)
                      ? AppColors.primary
                      : AppColors.textMuted,
                  fontWeight: NallaDateUtils.isToday(day)
                      ? FontWeight.w800
                      : FontWeight.w600,
                )),
          ],
        );
      }),
    );
  }
}

// Thin wrapper to avoid importing full score_calculator in widget
abstract class ScoreCalculatorHelper {
  static bool earnedStar(double score) => score >= AppConstants.starThreshold;
}
