import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/group_provider.dart';
import '../../../core/services/score_calculator.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/daily_record_model.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/repositories/achievement_repository.dart';
import '../../../data/repositories/daily_record_repository.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../data/repositories/kid_repository.dart';
import '../widgets/daily_score_header.dart';
import '../widgets/day_navigator.dart';
import '../widgets/habit_tile.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

/// Records for a specific kid + date, rebuilds whenever Hive changes.
final _dayRecordsProvider = StreamProvider.autoDispose
    .family<List<DailyRecordModel>, ({String kidId, DateTime date})>(
        (ref, args) {
  final repo = ref.watch(dailyRecordRepositoryProvider);
  return repo.watchDay(args.kidId, args.date);
});

// ── Screen ───────────────────────────────────────────────────────────────────

class DailyTrackerScreen extends ConsumerStatefulWidget {
  final String kidId;
  final DateTime date;

  const DailyTrackerScreen({
    super.key,
    required this.kidId,
    required this.date,
  });

  @override
  ConsumerState<DailyTrackerScreen> createState() => _DailyTrackerScreenState();
}

class _DailyTrackerScreenState extends ConsumerState<DailyTrackerScreen> {
  late DateTime _date;
  late ConfettiController _confetti;
  bool _celebratedToday = false;
  Timer? _syncDebounce;

  @override
  void initState() {
    super.initState();
    // Normalise to midnight so comparisons are stable
    _date = DateTime(widget.date.year, widget.date.month, widget.date.day);
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _syncDebounce?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  bool _isToday() {
    final now = DateTime.now();
    return _date.year == now.year &&
        _date.month == now.month &&
        _date.day == now.day;
  }

  Future<void> _toggle(
    String habitId,
    bool newValue,
    List<HabitModel> positiveHabits,
  ) async {
    final repo = ref.read(dailyRecordRepositoryProvider);
    await repo.setCompleted(widget.kidId, habitId, _date, newValue);

    // Fire confetti once per day when the star threshold is first crossed
    if (_isToday() && !_celebratedToday) {
      final records = repo.getForDay(widget.kidId, _date);
      final completedIds = ScoreCalculator.completedIdsFromRecords(records);
      final score = ScoreCalculator.dailyScore(
        positiveHabits: positiveHabits,
        completedIds: completedIds,
      );
      if (ScoreCalculator.earnedStar(score)) {
        setState(() => _celebratedToday = true);
        _confetti.play();
      }
    }

    // Debounce sync so rapid taps don't spam Firestore
    if (_isToday()) _scheduleSyncIfNeeded();
  }

  void _scheduleSyncIfNeeded() {
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 2), () {
      final firebaseReady = ref.read(firebaseReadyProvider);
      if (!firebaseReady) return;

      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final group = ref.read(userGroupProvider).valueOrNull;
      if (group == null) return;

      final kids = ref.read(kidsListProvider);
      if (kids.isEmpty) return;

      final achievementRepo = ref.read(achievementRepositoryProvider);
      SyncService.syncAllKids(
        kids: kids,
        userId: user.uid,
        groupId: group.id,
        achievementRepo: achievementRepo,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final positiveHabits = ref.watch(positiveHabitsProvider);
    final negativeHabits = ref.watch(negativeHabitsProvider);
    final key = (kidId: widget.kidId, date: _date);
    final recordsAsync = ref.watch(_dayRecordsProvider(key));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      body: Stack(
        children: [
          Column(
            children: [
              // Gradient header + animated score ring
              _buildHeader(positiveHabits, negativeHabits, recordsAsync),

              // Sticky day navigator
              DayNavigator(
                date: _date,
                onDateChanged: (d) => setState(
                  () => _date =
                      DateTime(d.year, d.month, d.day),
                ),
              ),

              // Scrollable habit list
              Expanded(
                child: recordsAsync.when(
                  data: (records) => _HabitList(
                    positiveHabits: positiveHabits,
                    negativeHabits: negativeHabits,
                    records: records,
                    isToday: _isToday(),
                    isPastDay: _date.isBefore(DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                    )),
                    onToggle: (habitId, val) =>
                        _toggle(habitId, val, positiveHabits),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load habits 😕\n$e',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Confetti burst from top-centre
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 45,
              maxBlastForce: 35,
              minBlastForce: 12,
              emissionFrequency: 0.04,
              gravity: 0.28,
              shouldLoop: false,
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

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(
    List<HabitModel> positiveHabits,
    List<HabitModel> negativeHabits,
    AsyncValue<List<DailyRecordModel>> recordsAsync,
  ) {
    final records = recordsAsync.valueOrNull ?? [];
    final completedIds = ScoreCalculator.completedIdsFromRecords(records);

    final score = ScoreCalculator.dailyScore(
      positiveHabits: positiveHabits,
      completedIds: completedIds,
    );
    final deductions = ScoreCalculator.dailyDeductions(
      negativeHabits: negativeHabits,
      completedIds: completedIds,
    );
    final completedCount =
        positiveHabits.where((h) => completedIds.contains(h.id)).length;

    return Column(
      children: [
        // App bar row
        Container(
          decoration: const BoxDecoration(gradient: AppColors.purplePinkGradient),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      '📅  Daily Habits',
                      style: AppTextStyles.h4.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Score ring
        DailyScoreHeader(
          score: score,
          completedCount: completedCount,
          totalCount: positiveHabits.length,
          deductionCount: deductions,
        ),
      ],
    );
  }
}

// ── Habit list (extracted for clarity) ────────────────────────────────────────

class _HabitList extends StatelessWidget {
  final List<HabitModel> positiveHabits;
  final List<HabitModel> negativeHabits;
  final List<DailyRecordModel> records;
  final bool isToday;
  final bool isPastDay;
  final void Function(String habitId, bool value) onToggle;

  const _HabitList({
    required this.positiveHabits,
    required this.negativeHabits,
    required this.records,
    required this.isToday,
    required this.isPastDay,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final completedIds = ScoreCalculator.completedIdsFromRecords(records);
    final readOnly = isPastDay && !isToday;
    final doneCount = positiveHabits
        .where((h) => completedIds.contains(h.id))
        .length;

    return ListView(
      padding: const EdgeInsets.only(top: 14, bottom: 40),
      children: [
        // ── Positive habits ─────────────────────────────────────────
        _SectionHeader(
          emoji: '✅',
          title: 'Good Habits',
          subtitle: '$doneCount / ${positiveHabits.length} done',
          color: AppColors.success,
        ),

        if (positiveHabits.isEmpty)
          const _EmptySection(message: 'No active habits — add some in Settings'),

        ...positiveHabits.map((habit) => HabitTile(
              habit: habit,
              isCompleted: completedIds.contains(habit.id),
              onToggle: readOnly ? (_) {} : (v) => onToggle(habit.id, v),
            )),

        // ── Negative behaviours ─────────────────────────────────────
        if (negativeHabits.isNotEmpty) ...[
          const SizedBox(height: 10),
          _SectionHeader(
            emoji: '⚠️',
            title: 'Behaviour Marks',
            subtitle: 'tap if it happened today',
            color: AppColors.danger,
          ),
          ...negativeHabits.map((habit) => HabitTile(
                habit: habit,
                isCompleted: completedIds.contains(habit.id),
                onToggle: readOnly ? (_) {} : (v) => onToggle(habit.id, v),
              )),
        ],

        const SizedBox(height: 16),

        // ── Read-only notice ────────────────────────────────────────
        if (readOnly)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.20)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 15, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    'Past day — view only',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),

        // ── Star tip (today only) ────────────────────────────────────
        if (isToday)
          Padding(
            padding:
                const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: Text(
              '⭐ Complete ${(AppConstants.starThreshold * 100).round()}% of good habits to earn today\'s star!',
              style: AppTextStyles.bodySmall
                  .copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

// ── Small helper widgets ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(title, style: AppTextStyles.label.copyWith(color: color)),
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall
                .copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[400]),
        textAlign: TextAlign.center,
      ),
    );
  }
}
