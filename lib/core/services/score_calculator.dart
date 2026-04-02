import '../constants/app_constants.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/daily_record_model.dart';

/// Pure, stateless scoring logic — no Hive, no Flutter, fully unit-testable.
///
/// [ScoreService] delegates to these static methods so they can be
/// tested in isolation without any Hive setup.
abstract class ScoreCalculator {
  // ── Daily ─────────────────────────────────────────────────────

  /// Fraction of positive habits completed on a given day (0.0–1.0).
  ///
  /// [positiveHabits]  — all active positive habits
  /// [completedIds]    — habit IDs that are marked done that day
  static double dailyScore({
    required List<HabitModel> positiveHabits,
    required Set<String> completedIds,
  }) {
    if (positiveHabits.isEmpty) return 0.0;
    final done =
        positiveHabits.where((h) => completedIds.contains(h.id)).length;
    return done / positiveHabits.length;
  }

  /// Number of negative-behaviour habits that were triggered on a day.
  static int dailyDeductions({
    required List<HabitModel> negativeHabits,
    required Set<String> completedIds,
  }) =>
      negativeHabits.where((h) => completedIds.contains(h.id)).length;

  /// A ⭐ is earned when daily score meets or exceeds the threshold.
  static bool earnedStar(double score) =>
      score >= AppConstants.starThreshold;

  // ── Weekly ────────────────────────────────────────────────────

  /// Average daily score across a list of per-day scores.
  static double weeklyAverage(List<double> dailyScores) {
    if (dailyScores.isEmpty) return 0.0;
    return dailyScores.reduce((a, b) => a + b) / dailyScores.length;
  }

  /// Stars earned in a week (one per day where score ≥ threshold).
  static int weeklyStars(List<double> dailyScores) =>
      dailyScores.where(earnedStar).length;

  // ── Monthly ───────────────────────────────────────────────────

  /// Monthly score = average daily score minus deduction penalty (0.0–1.0).
  ///
  /// Each negative occurrence reduces the score by
  /// [AppConstants.negativeDeductionPoints] / 100.
  static double monthlyScore({
    required List<double> dailyScores,
    required int totalDeductions,
  }) {
    if (dailyScores.isEmpty) return 0.0;
    final avg = dailyScores.reduce((a, b) => a + b) / dailyScores.length;
    final penalty =
        (totalDeductions * AppConstants.negativeDeductionPoints) / 100.0;
    return (avg - penalty).clamp(0.0, 1.0);
  }

  // ── Levels ────────────────────────────────────────────────────

  /// Map a monthly score to a level (1–5).
  static int scoreToLevel(double score) {
    if (score >= AppConstants.level5Threshold) return 5;
    if (score >= AppConstants.level4Threshold) return 4;
    if (score >= AppConstants.level3Threshold) return 3;
    if (score >= AppConstants.level2Threshold) return 2;
    return 1;
  }

  /// Whether the hold rule should be applied (score dropped > 20% vs last month).
  static bool shouldHoldLevel({
    required double previousScore,
    required double currentScore,
  }) =>
      (previousScore - currentScore) > AppConstants.levelHoldDropThreshold;

  /// Final level after applying hold rule.
  static int resolveLevel({
    required double currentScore,
    required int levelBefore,
    double? previousMonthScore,
  }) {
    final target = scoreToLevel(currentScore);
    if (previousMonthScore != null &&
        shouldHoldLevel(
            previousScore: previousMonthScore, currentScore: currentScore)) {
      return levelBefore; // hold — no promotion AND no demotion
    }
    return target;
  }

  // ── Helpers ───────────────────────────────────────────────────

  /// Extract the set of completed habit IDs from a list of records for one day.
  static Set<String> completedIdsFromRecords(
          List<DailyRecordModel> dayRecords) =>
      dayRecords.where((r) => r.completed).map((r) => r.habitId).toSet();

  /// Human-readable percentage string, e.g. "87%".
  static String toPercent(double score) =>
      '${(score * 100).round()}%';
}
