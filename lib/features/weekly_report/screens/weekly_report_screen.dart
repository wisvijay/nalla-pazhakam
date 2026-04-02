import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/score_calculator.dart';
import '../../../core/services/score_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/repositories/kid_repository.dart';
import '../../../shared/widgets/kid_avatar.dart';
import '../../../shared/widgets/level_badge.dart';

class WeeklyReportScreen extends ConsumerStatefulWidget {
  final String kidId;

  const WeeklyReportScreen({super.key, required this.kidId});

  @override
  ConsumerState<WeeklyReportScreen> createState() =>
      _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends ConsumerState<WeeklyReportScreen> {
  late DateTime _weekDate; // any day within the current week
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _weekDate = DateTime.now();
    _confetti = ConfettiController(
        duration: const Duration(seconds: 2));
    // Auto-celebrate if it was a great week (5+ stars)
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeCelebrate());
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _maybeCelebrate() {
    final stats = ref
        .read(scoreServiceProvider)
        .getWeeklyStats(widget.kidId, _weekDate);
    if (stats.starsEarned >= 5) _confetti.play();
  }

  @override
  Widget build(BuildContext context) {
    final kid = ref.watch(kidRepositoryProvider).getById(widget.kidId);
    if (kid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Weekly Report')),
        body: const Center(child: Text('Child not found')),
      );
    }

    final scoreService = ref.watch(scoreServiceProvider);
    final stats = scoreService.getWeeklyStats(widget.kidId, _weekDate);
    final weekStart = NallaDateUtils.weekStart(_weekDate);
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final isCurrentWeek = NallaDateUtils.isSameDay(
        NallaDateUtils.weekStart(today), weekStart);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero header ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  // Previous week
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: Colors.white),
                    onPressed: () => setState(() => _weekDate =
                        _weekDate.subtract(const Duration(days: 7))),
                  ),
                  // Next week (disabled for current week)
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded,
                        color: isCurrentWeek
                            ? Colors.white30
                            : Colors.white),
                    onPressed: isCurrentWeek
                        ? null
                        : () => setState(() => _weekDate =
                            _weekDate.add(const Duration(days: 7))),
                  ),
                  const SizedBox(width: 4),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                        gradient: AppColors.heroGradient),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 44),
                        KidAvatar(
                            name: kid.name,
                            photoBase64: kid.photoBase64,
                            size: 64),
                        const SizedBox(height: 8),
                        Text(kid.name,
                            style: AppTextStyles.h3
                                .copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          NallaDateUtils.formatWeekRange(weekStart),
                          style: AppTextStyles.body
                              .copyWith(color: Colors.white70),
                        ),
                        if (isCurrentWeek) ...[
                          const SizedBox(height: 6),
                          _PillChip(
                              label: 'Current Week',
                              color: Colors.white24),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // ── Content ──────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stars earned card
                    _StarSummaryCard(stats: stats),
                    const SizedBox(height: 14),

                    // Daily breakdown
                    _DailyBreakdownCard(
                      stats: stats,
                      weekStart: weekStart,
                      today: today,
                      onDayTap: (date) => context.push(
                        '${AppRoutes.dailyTracker.replaceFirst(':kidId', widget.kidId)}'
                        '?date=${NallaDateUtils.dayKey(date)}',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Stats summary
                    _StatsSummaryCard(stats: stats, kid: kid),
                    const SizedBox(height: 14),

                    // Motivational footer
                    _MotivationalBanner(
                        starsEarned: stats.starsEarned),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 35,
              gravity: 0.3,
              colors: const [
                Color(0xFF7C3AED),
                Color(0xFFEC4899),
                Color(0xFFF59E0B),
                Color(0xFF10B981),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Star summary card ─────────────────────────────────────────────────────────

class _StarSummaryCard extends StatelessWidget {
  final WeeklyStats stats;
  const _StarSummaryCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          // Big star row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (i) {
              final earned = i < stats.starsEarned;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AnimatedScale(
                  scale: earned ? 1.0 : 0.7,
                  duration: Duration(milliseconds: 200 + i * 60),
                  curve: Curves.elasticOut,
                  child: Text(
                    earned ? '⭐' : '☆',
                    style: TextStyle(
                      fontSize: earned ? 28 : 22,
                      color: earned
                          ? AppColors.accent
                          : Colors.grey[300],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            '${stats.starsEarned} star${stats.starsEarned != 1 ? 's' : ''} earned',
            style: AppTextStyles.h3.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: 4),
          Text(
            'out of 7 possible this week',
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stats.starsEarned / 7.0,
              backgroundColor: Colors.grey.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                stats.starsEarned >= 5
                    ? AppColors.success
                    : AppColors.accent,
              ),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily breakdown card ──────────────────────────────────────────────────────

class _DailyBreakdownCard extends StatelessWidget {
  final WeeklyStats stats;
  final DateTime weekStart;
  final DateTime today;
  final ValueChanged<DateTime> onDayTap;

  const _DailyBreakdownCard({
    required this.stats,
    required this.weekStart,
    required this.today,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Breakdown', style: AppTextStyles.h4),
          const SizedBox(height: 14),
          Row(
            children: List.generate(7, (i) {
              final day = weekStart.add(Duration(days: i));
              final isPast = !day.isAfter(today);
              final hasScore = i < stats.dailyScores.length;
              final score = hasScore ? stats.dailyScores[i] : 0.0;
              final earned = hasScore && ScoreCalculator.earnedStar(score);
              final isToday = NallaDateUtils.isToday(day);

              return Expanded(
                child: GestureDetector(
                  onTap: isPast ? () => onDayTap(day) : null,
                  child: Column(
                    children: [
                      // Mini bar
                      Container(
                        height: 56,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 3),
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration:
                              Duration(milliseconds: 300 + i * 50),
                          curve: Curves.easeOutCubic,
                          width: 22,
                          height: isPast ? (score * 56).clamp(4.0, 56.0) : 4,
                          decoration: BoxDecoration(
                            color: earned
                                ? AppColors.success
                                : isPast
                                    ? AppColors.accent
                                        .withValues(alpha: 0.45)
                                    : Colors.grey
                                        .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Star or percent
                      Text(
                        earned
                            ? '⭐'
                            : isPast && hasScore
                                ? '${(score * 100).round()}%'
                                : '—',
                        style: TextStyle(
                          fontSize: earned ? 14 : 9,
                          color: isPast
                              ? AppColors.textPrimary
                              : Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Day label
                      Text(
                        dayLabels[i],
                        style: AppTextStyles.caption.copyWith(
                          color: isToday
                              ? AppColors.primary
                              : Colors.grey[500],
                          fontWeight: isToday
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a day bar to review its habits',
            style: AppTextStyles.caption
                .copyWith(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

// ── Stats summary card ────────────────────────────────────────────────────────

class _StatsSummaryCard extends StatelessWidget {
  final WeeklyStats stats;
  final dynamic kid;

  const _StatsSummaryCard({required this.stats, required this.kid});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Week Stats', style: AppTextStyles.h4),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatTile(
                emoji: '⭐',
                value: '${stats.starsEarned}/7',
                label: 'Stars',
                color: AppColors.accent,
              ),
              const SizedBox(width: 10),
              _StatTile(
                emoji: '📊',
                value: stats.percentLabel,
                label: 'Average',
                color: AppColors.info,
              ),
              const SizedBox(width: 10),
              _StatTile(
                emoji: '⚠️',
                value: '${stats.totalDeductions}',
                label: 'Deductions',
                color: AppColors.danger,
              ),
              const SizedBox(width: 10),
              _StatTile(
                emoji: '📅',
                value: '${stats.daysTracked}',
                label: 'Days',
                color: AppColors.success,
              ),
            ],
          ),
          if (kid != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('Current Level: ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                LevelBadge(level: kid.currentLevel, compact: true),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Motivational banner ───────────────────────────────────────────────────────

class _MotivationalBanner extends StatelessWidget {
  final int starsEarned;
  const _MotivationalBanner({required this.starsEarned});

  @override
  Widget build(BuildContext context) {
    final (emoji, title, subtitle) = switch (starsEarned) {
      7 => ('🏆', 'Perfect Week!', 'Absolutely amazing — 7 out of 7 stars!'),
      >= 5 => ('🎉', 'Fantastic Week!',
          '$starsEarned stars! Keep this energy going!'),
      >= 3 => ('💪', 'Good Effort!',
          '$starsEarned stars earned. Push for even more next week!'),
      1 || 2 => ('🌱', 'Keep Growing!',
          '$starsEarned star${starsEarned != 1 ? 's' : ''} — every habit counts!'),
      _ => ('😊', 'Start Fresh!',
          'Tomorrow is a new chance to build great habits!'),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: starsEarned >= 5
            ? AppColors.goldGradient
            : starsEarned >= 3
                ? AppColors.greenBlueGradient
                : AppColors.purplePinkGradient,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.h4
                        .copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTextStyles.body
                        .copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );
}

class _StatTile extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 4),
              Text(value,
                  style: AppTextStyles.label.copyWith(color: color)),
              Text(label,
                  style:
                      AppTextStyles.caption.copyWith(color: Colors.grey[500])),
            ],
          ),
        ),
      );
}

class _PillChip extends StatelessWidget {
  final String label;
  final Color color;
  const _PillChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(color: Colors.white),
        ),
      );
}
