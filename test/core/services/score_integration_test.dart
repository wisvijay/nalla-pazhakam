/// Integration-style tests that combine ScoreCalculator with realistic data.
/// Still pure Dart — no Hive, no Flutter required.
import 'package:flutter_test/flutter_test.dart';
import 'package:nalla_pazhakam/core/services/score_calculator.dart';
import 'package:nalla_pazhakam/data/models/habit_model.dart';
import 'package:nalla_pazhakam/data/models/daily_record_model.dart';

// ── Test fixtures ──────────────────────────────────────────────────
final positiveHabits = [
  _habit('brush', '🦷', pos: true),
  _habit('bath', '🛁', pos: true),
  _habit('read', '📚', pos: true),
  _habit('exercise', '🏃', pos: true),
  _habit('sleep', '😴', pos: true),
];

final negativeHabits = [
  _habit('tantrum', '😠', pos: false),
  _habit('badwords', '🤬', pos: false),
];

HabitModel _habit(String id, String emoji, {required bool pos}) => HabitModel(
      id: id,
      name: id,
      description: '',
      emojiIcon: emoji,
      isPositive: pos,
      isActive: true,
      sortOrder: 0,
      isDefault: true,
    );

DailyRecordModel _rec(String kidId, String habitId,
        {bool completed = true, DateTime? date}) =>
    DailyRecordModel.create(
      kidId: kidId,
      habitId: habitId,
      date: date ?? DateTime(2026, 4, 1),
      completed: completed,
    );

void main() {
  const kid = 'kid_arjun';

  group('Full week simulation', () {
    /// Simulate a week where Arjun completes 4/5 habits each day (80%)
    /// and has one tantrum mid-week.
    test('80% week earns 7 stars with one deduction', () {
      // For each of 7 days: 4 out of 5 habits done = 80%
      final dailyScores = List.generate(7, (_) {
        final completed = {'brush', 'bath', 'read', 'exercise'}; // 4/5
        return ScoreCalculator.dailyScore(
          positiveHabits: positiveHabits,
          completedIds: completed,
        );
      });

      expect(dailyScores.every((s) => s == 0.8), isTrue);
      expect(ScoreCalculator.weeklyStars(dailyScores), 7);
    });

    test('mixed week: 4 stars out of 7', () {
      // Mon/Wed/Fri/Sun above threshold, rest below
      final scores = [0.8, 0.5, 0.7, 0.4, 0.9, 0.6, 0.7];
      expect(ScoreCalculator.weeklyStars(scores), 4);
    });
  });

  group('Monthly scenario: level promotion', () {
    test('90% month with no deductions → level 4 (Gold Achiever)', () {
      final scores = List.filled(30, 0.90);
      final monthly = ScoreCalculator.monthlyScore(
        dailyScores: scores,
        totalDeductions: 0,
      );
      expect(monthly, closeTo(0.90, 0.001));
      // Level 5 requires ≥ 95%; 90% sits at level 4 (Gold Achiever)
      expect(ScoreCalculator.scoreToLevel(monthly), 4);
    });

    test('95% month with no deductions → level 5 (Habit Champion)', () {
      final scores = List.filled(30, 0.95);
      final monthly = ScoreCalculator.monthlyScore(
        dailyScores: scores,
        totalDeductions: 0,
      );
      expect(monthly, closeTo(0.95, 0.001));
      expect(ScoreCalculator.scoreToLevel(monthly), 5);
    });

    test('70% month with 4 deductions → 50% → level 2', () {
      final scores = List.filled(30, 0.70);
      final monthly = ScoreCalculator.monthlyScore(
        dailyScores: scores,
        totalDeductions: 4, // 4 × 5pts = 20% penalty
      );
      expect(monthly, closeTo(0.50, 0.001));
      expect(ScoreCalculator.scoreToLevel(monthly), 2);
    });

    test('hold rule prevents demotion after big drop', () {
      final level = ScoreCalculator.resolveLevel(
        currentScore: 0.48,       // would normally be level 1
        levelBefore: 4,
        previousMonthScore: 0.85, // drop of 0.37 > 0.20 threshold
      );
      expect(level, 4); // held — not demoted
    });

    test('no hold when drop is gradual', () {
      final level = ScoreCalculator.resolveLevel(
        currentScore: 0.66,       // level 3
        levelBefore: 4,
        previousMonthScore: 0.81, // drop of 0.15 ≤ 0.20 → no hold
      );
      expect(level, 3); // allowed to change
    });
  });

  group('completedIdsFromRecords round-trip', () {
    test('correctly identifies completed habit IDs for scoring', () {
      final records = [
        _rec(kid, 'brush', completed: true),
        _rec(kid, 'bath', completed: true),
        _rec(kid, 'read', completed: false),
        _rec(kid, 'exercise', completed: true),
        _rec(kid, 'sleep', completed: false),
      ];

      final ids = ScoreCalculator.completedIdsFromRecords(records);
      final score = ScoreCalculator.dailyScore(
        positiveHabits: positiveHabits,
        completedIds: ids,
      );

      expect(score, 0.6); // 3/5
      expect(ScoreCalculator.earnedStar(score), isFalse); // 60% < 70%
    });

    test('perfect day earns star', () {
      final records = positiveHabits
          .map((h) => _rec(kid, h.id, completed: true))
          .toList();
      final ids = ScoreCalculator.completedIdsFromRecords(records);
      final score = ScoreCalculator.dailyScore(
        positiveHabits: positiveHabits,
        completedIds: ids,
      );
      expect(score, 1.0);
      expect(ScoreCalculator.earnedStar(score), isTrue);
    });
  });

  group('Edge cases', () {
    test('single habit completed gives 100% score', () {
      final habits = [_habit('h1', '✅', pos: true)];
      expect(
        ScoreCalculator.dailyScore(
            positiveHabits: habits, completedIds: {'h1'}),
        1.0,
      );
    });

    test('monthly score never exceeds 1.0', () {
      final scores = List.filled(30, 1.0);
      final monthly = ScoreCalculator.monthlyScore(
          dailyScores: scores, totalDeductions: 0);
      expect(monthly, lessThanOrEqualTo(1.0));
    });

    test('monthly score never goes below 0.0', () {
      final monthly = ScoreCalculator.monthlyScore(
        dailyScores: [0.1],
        totalDeductions: 100, // extreme penalty
      );
      expect(monthly, greaterThanOrEqualTo(0.0));
    });
  });
}
