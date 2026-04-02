import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/score_calculator.dart';
import '../../../core/services/score_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/monthly_report_model.dart';
import '../../../data/repositories/achievement_repository.dart';
import '../../../data/repositories/kid_repository.dart';
import '../../../shared/widgets/kid_avatar.dart';
import '../../../shared/widgets/level_badge.dart';

class MonthlyReportScreen extends ConsumerStatefulWidget {
  final String kidId;

  const MonthlyReportScreen({super.key, required this.kidId});

  @override
  ConsumerState<MonthlyReportScreen> createState() =>
      _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends ConsumerState<MonthlyReportScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _month; // first day of the viewed month
  late ConfettiController _confetti;
  late AnimationController _levelAnim;
  bool _computingReport = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _confetti = ConfettiController(
        duration: const Duration(seconds: 4));
    _levelAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _checkPromotion());
  }

  @override
  void dispose() {
    _confetti.dispose();
    _levelAnim.dispose();
    super.dispose();
  }

  void _checkPromotion() {
    final report = ref.read(achievementRepositoryProvider).getMonthly(
        widget.kidId, _month.year, _month.month);
    if (report != null && report.promoted) {
      _confetti.play();
      _levelAnim.forward();
    }
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  Future<void> _generateReport() async {
    if (_computingReport) return;
    setState(() => _computingReport = true);
    try {
      final report = await ref.read(scoreServiceProvider).computeAndSaveMonthly(
            widget.kidId,
            _month.year,
            _month.month,
          );
      if (report.promoted && mounted) {
        _confetti.play();
        _levelAnim.forward(from: 0);
      }
    } finally {
      if (mounted) setState(() => _computingReport = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kid = ref.watch(kidRepositoryProvider).getById(widget.kidId);
    if (kid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Monthly Report')),
        body: const Center(child: Text('Child not found')),
      );
    }

    final achievementRepo = ref.watch(achievementRepositoryProvider);
    final savedReport = achievementRepo.getMonthly(
        widget.kidId, _month.year, _month.month);

    // Live score for the current (un-finalized) month
    final liveScore = _isCurrentMonth
        ? ref
            .watch(scoreServiceProvider)
            .getMonthlyScore(widget.kidId, _month.year, _month.month)
        : savedReport?.finalScore ?? 0.0;

    final level = ScoreCalculator.scoreToLevel(liveScore);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero ─────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: Colors.white),
                    onPressed: () => setState(() => _month =
                        DateTime(_month.year, _month.month - 1, 1)),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded,
                        color: _isCurrentMonth
                            ? Colors.white30
                            : Colors.white),
                    onPressed: _isCurrentMonth
                        ? null
                        : () => setState(() => _month = DateTime(
                            _month.year, _month.month + 1, 1)),
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
                          NallaDateUtils.formatMonthYear(_month),
                          style: AppTextStyles.body
                              .copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        if (_isCurrentMonth)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'In Progress',
                              style: AppTextStyles.caption
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Score ring card
                    _ScoreRingCard(
                      score: liveScore,
                      level: level,
                      isCurrentMonth: _isCurrentMonth,
                    ),
                    const SizedBox(height: 14),

                    // Level badge + change
                    _LevelCard(
                      kid: kid,
                      savedReport: savedReport,
                      liveLevel: level,
                      animation: _levelAnim,
                    ),
                    const SizedBox(height: 14),

                    // Monthly history
                    _MonthlyHistoryCard(
                      kidId: widget.kidId,
                      achievementRepo: achievementRepo,
                      currentMonth: _month,
                    ),
                    const SizedBox(height: 14),

                    // Stats row
                    if (savedReport != null)
                      _MonthStatsCard(report: savedReport)
                    else if (_isCurrentMonth)
                      _LiveStatsCard(
                        kidId: widget.kidId,
                        month: _month,
                        score: liveScore,
                      ),

                    const SizedBox(height: 14),

                    // Generate / Finalise button
                    if (_isCurrentMonth || savedReport == null)
                      _GenerateButton(
                        loading: _computingReport,
                        hasReport: savedReport != null,
                        onPressed: _generateReport,
                      ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),

          // Confetti on level-up
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 50,
              gravity: 0.25,
              colors: const [
                Color(0xFF7C3AED),
                Color(0xFFEC4899),
                Color(0xFFF59E0B),
                Color(0xFF10B981),
                Color(0xFF3B82F6),
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Score ring card ───────────────────────────────────────────────────────────

class _ScoreRingCard extends StatelessWidget {
  final double score;
  final int level;
  final bool isCurrentMonth;

  const _ScoreRingCard({
    required this.score,
    required this.level,
    required this.isCurrentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (score * 100).round();
    final color = _levelColor(level);

    return _Card(
      child: Row(
        children: [
          // Ring
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    color: Colors.grey.withValues(alpha: 0.12),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, val, __) => SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: val,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      color: color,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: AppTextStyles.h3.copyWith(color: color),
                    ),
                    Text(
                      'score',
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentMonth
                      ? 'Month in Progress'
                      : 'Final Score',
                  style: AppTextStyles.label
                      .copyWith(color: Colors.grey[500]),
                ),
                const SizedBox(height: 6),
                Text(
                  ScoreCalculator.toPercent(score),
                  style: AppTextStyles.h2.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.levelNames[level - 1],
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                // Score bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: score),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, val, __) =>
                        LinearProgressIndicator(
                      value: val,
                      backgroundColor:
                          Colors.grey.withValues(alpha: 0.12),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _levelColor(int level) {
    return switch (level) {
      1 => AppColors.levelSeedling,
      2 => AppColors.levelStarLearner,
      3 => AppColors.levelRisingStar,
      4 => AppColors.levelGoldAchiever,
      _ => AppColors.levelChampion,
    };
  }
}

// ── Level card ────────────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  final dynamic kid;
  final MonthlyReportModel? savedReport;
  final int liveLevel;
  final AnimationController animation;

  const _LevelCard({
    required this.kid,
    required this.savedReport,
    required this.liveLevel,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final promoted = savedReport?.promoted ?? false;
    final levelBefore = savedReport?.levelBefore ?? kid.currentLevel;
    final levelAfter = savedReport?.levelAfter ?? liveLevel;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Level Status', style: AppTextStyles.h4),
          const SizedBox(height: 14),
          if (promoted) ...[
            // Level-up animation row
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) => Opacity(
                opacity: animation.value,
                child: child,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LevelPill(level: levelBefore, dimmed: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppColors.success),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            'PROMOTED!',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _LevelPill(level: levelAfter, highlight: true),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '🎉 Congratulations! You\'ve reached ${AppConstants.levelNames[levelAfter - 1]}!',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.success),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            Row(
              children: [
                LevelBadge(level: kid.currentLevel),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppConstants.levelNames[kid.currentLevel - 1],
                          style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700)),
                      Text(
                        savedReport != null
                            ? 'Level maintained this month'
                            : _nextLevelHint(kid.currentLevel, liveLevel),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _nextLevelHint(int current, int projected) {
    if (projected > current) {
      return '${AppConstants.levelEmojis[projected - 1]} On track for ${AppConstants.levelNames[projected - 1]}!';
    }
    if (current < 5) {
      final needed = AppConstants.levelThresholds[current];
      return 'Keep at ${(needed * 100).round()}%+ to reach level ${current + 1}';
    }
    return '🏆 You\'re at the top level!';
  }
}

// ── Monthly history card ──────────────────────────────────────────────────────

class _MonthlyHistoryCard extends StatelessWidget {
  final String kidId;
  final AchievementRepository achievementRepo;
  final DateTime currentMonth;

  const _MonthlyHistoryCard({
    required this.kidId,
    required this.achievementRepo,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    // Last 6 months
    final months = List.generate(6, (i) {
      final m = DateTime(currentMonth.year, currentMonth.month - i, 1);
      return m;
    }).reversed.toList();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 6 Months', style: AppTextStyles.h4),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: months.map((m) {
              final report =
                  achievementRepo.getMonthly(kidId, m.year, m.month);
              final score = report?.finalScore ?? 0.0;
              final isCurrent = m.year == currentMonth.year &&
                  m.month == currentMonth.month;
              final barHeight = (score * 60).clamp(4.0, 60.0);

              return Expanded(
                child: Column(
                  children: [
                    // Score label
                    Text(
                      score > 0
                          ? ScoreCalculator.toPercent(score)
                          : '—',
                      style: AppTextStyles.caption.copyWith(
                        color: isCurrent
                            ? AppColors.primary
                            : Colors.grey[500],
                        fontWeight: isCurrent
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Bar
                    Container(
                      height: 60,
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        width: 22,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primary
                              : score >= AppConstants.level4Threshold
                                  ? AppColors.success
                                  : AppColors.accent
                                      .withValues(alpha: 0.50),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Month label
                    Text(
                      _shortMonth(m.month),
                      style: AppTextStyles.caption.copyWith(
                          color: isCurrent
                              ? AppColors.primary
                              : Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _shortMonth(int m) {
    const months = [
      'J', 'F', 'M', 'A', 'M', 'J',
      'J', 'A', 'S', 'O', 'N', 'D'
    ];
    return months[m - 1];
  }
}

// ── Stats cards ───────────────────────────────────────────────────────────────

class _MonthStatsCard extends StatelessWidget {
  final MonthlyReportModel report;
  const _MonthStatsCard({required this.report});

  @override
  Widget build(BuildContext context) => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Month Summary', style: AppTextStyles.h4),
            const SizedBox(height: 14),
            _StatsRow(
              items: [
                ('⭐', '${report.totalStars}', 'Stars'),
                ('⚠️', '${report.totalDeductions}', 'Deductions'),
                ('📊', report.scorePercent, 'Final Score'),
              ],
            ),
          ],
        ),
      );
}

class _LiveStatsCard extends StatelessWidget {
  final String kidId;
  final DateTime month;
  final double score;

  const _LiveStatsCard({
    required this.kidId,
    required this.month,
    required this.score,
  });

  @override
  Widget build(BuildContext context) => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Month So Far', style: AppTextStyles.h4),
            const SizedBox(height: 14),
            _StatsRow(
              items: [
                ('📊', ScoreCalculator.toPercent(score), 'Score'),
                ('🏆', AppConstants.levelEmojis[
                    ScoreCalculator.scoreToLevel(score) - 1], 'Level'),
                ('📅', '${DateTime.now().day}', 'Days In'),
              ],
            ),
          ],
        ),
      );
}

class _StatsRow extends StatelessWidget {
  final List<(String, String, String)> items;
  const _StatsRow({required this.items});

  @override
  Widget build(BuildContext context) => Row(
        children: items.map((item) {
          final (emoji, value, label) = item;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 6),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.primary)),
                  Text(label, style: AppTextStyles.caption),
                ],
              ),
            ),
          );
        }).toList(),
      );
}

// ── Generate report button ────────────────────────────────────────────────────

class _GenerateButton extends StatelessWidget {
  final bool loading;
  final bool hasReport;
  final VoidCallback onPressed;

  const _GenerateButton({
    required this.loading,
    required this.hasReport,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: loading ? null : onPressed,
          icon: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(hasReport
                  ? Icons.refresh_rounded
                  : Icons.calculate_rounded),
          label: Text(hasReport
              ? 'Recalculate Report'
              : 'Generate Monthly Report'),
        ),
      );
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
          borderRadius:
              BorderRadius.circular(AppConstants.cardRadius),
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

class _LevelPill extends StatelessWidget {
  final int level;
  final bool highlight;
  final bool dimmed;

  const _LevelPill(
      {required this.level, this.highlight = false, this.dimmed = false});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: dimmed ? 0.5 : 1.0,
        child: LevelBadge(level: level),
      );
}
