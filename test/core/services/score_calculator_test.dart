import 'package:flutter_test/flutter_test.dart';
import 'package:nalla_pazhakam/core/services/score_calculator.dart';
import 'package:nalla_pazhakam/core/constants/app_constants.dart';
import 'package:nalla_pazhakam/data/models/habit_model.dart';
import 'package:nalla_pazhakam/data/models/daily_record_model.dart';

// ── Helpers ────────────────────────────────────────────────────────
HabitModel _habit(String id,
        {bool isPositive = true, bool isActive = true}) =>
    HabitModel(
      id: id,
      name: 'Habit $id',
      description: '',
      emojiIcon: '✅',
      isPositive: isPositive,
      isActive: isActive,
      sortOrder: 0,
      isDefault: true,
    );

DailyRecordModel _record(String kidId, String habitId,
        {bool completed = true}) =>
    DailyRecordModel.create(
      kidId: kidId,
      habitId: habitId,
      date: DateTime(2026, 4, 1),
      completed: completed,
    );

void main() {
  group('ScoreCalculator', () {
    // ── dailyScore ───────────────────────────────────────────
    group('dailyScore', () {
      test('returns 1.0 when all habits completed', () {
        final habits = [_habit('h1'), _habit('h2'), _habit('h3')];
        final score = ScoreCalculator.dailyScore(
          positiveHabits: habits,
          completedIds: {'h1', 'h2', 'h3'},
        );
        expect(score, 1.0);
      });

      test('returns 0.0 when nothing completed', () {
        final habits = [_habit('h1'), _habit('h2')];
        final score = ScoreCalculator.dailyScore(
          positiveHabits: habits,
          completedIds: {},
        );
        expect(score, 0.0);
      });

      test('returns correct fraction', () {
        final habits = [_habit('h1'), _habit('h2'), _habit('h3'), _habit('h4')];
        final score = ScoreCalculator.dailyScore(
          positiveHabits: habits,
          completedIds: {'h1', 'h3'}, // 2 out of 4
        );
        expect(score, 0.5);
      });

      test('returns 0.0 when no habits exist', () {
        final score = ScoreCalculator.dailyScore(
          positiveHabits: [],
          completedIds: {'h1'},
        );
        expect(score, 0.0);
      });

      test('ignores IDs not in positive habits list', () {
        final habits = [_habit('h1'), _habit('h2')];
        final score = ScoreCalculator.dailyScore(
          positiveHabits: habits,
          completedIds: {'h1', 'unknown_id'},
        );
        expect(score, 0.5);
      });
    });

    // ── earnedStar ───────────────────────────────────────────
    group('earnedStar', () {
      test('earns star at threshold (70%)', () {
        expect(ScoreCalculator.earnedStar(AppConstants.starThreshold),
            isTrue);
      });

      test('earns star above threshold', () {
        expect(ScoreCalculator.earnedStar(0.9), isTrue);
        expect(ScoreCalculator.earnedStar(1.0), isTrue);
      });

      test('does not earn star below threshold', () {
        expect(ScoreCalculator.earnedStar(0.69), isFalse);
        expect(ScoreCalculator.earnedStar(0.0), isFalse);
      });
    });

    // ── dailyDeductions ──────────────────────────────────────
    group('dailyDeductions', () {
      test('returns count of negative habits marked', () {
        final negHabits = [
          _habit('n1', isPositive: false),
          _habit('n2', isPositive: false),
          _habit('n3', isPositive: false),
        ];
        final count = ScoreCalculator.dailyDeductions(
          negativeHabits: negHabits,
          completedIds: {'n1', 'n3'},
        );
        expect(count, 2);
      });

      test('returns 0 when no negative habits marked', () {
        final negHabits = [_habit('n1', isPositive: false)];
        expect(
          ScoreCalculator.dailyDeductions(
              negativeHabits: negHabits, completedIds: {}),
          0,
        );
      });
    });

    // ── weeklyStars ──────────────────────────────────────────
    group('weeklyStars', () {
      test('counts days at or above threshold', () {
        final scores = [0.8, 0.5, 0.7, 0.9, 0.6, 1.0, 0.3];
        // 0.8✓ 0.5✗ 0.7✓ 0.9✓ 0.6✗ 1.0✓ 0.3✗ = 4 stars
        expect(ScoreCalculator.weeklyStars(scores), 4);
      });

      test('returns 0 for all-zero week', () {
        expect(ScoreCalculator.weeklyStars([0, 0, 0, 0, 0, 0, 0]), 0);
      });

      test('returns 7 for perfect week', () {
        expect(
            ScoreCalculator.weeklyStars([1, 1, 1, 1, 1, 1, 1]), 7);
      });
    });

    // ── weeklyAverage ────────────────────────────────────────
    group('weeklyAverage', () {
      test('computes mean correctly', () {
        final avg =
            ScoreCalculator.weeklyAverage([0.8, 0.6, 1.0, 0.4]);
        expect(avg, closeTo(0.7, 0.001));
      });

      test('returns 0 for empty list', () {
        expect(ScoreCalculator.weeklyAverage([]), 0.0);
      });
    });

    // ── monthlyScore ─────────────────────────────────────────
    group('monthlyScore', () {
      test('returns average minus deduction penalty', () {
        // avg = 0.80, 2 deductions × 5pts = 10% penalty
        final score = ScoreCalculator.monthlyScore(
          dailyScores: List.filled(30, 0.80),
          totalDeductions: 2,
        );
        expect(score, closeTo(0.70, 0.001));
      });

      test('clamps to 0.0 when deductions exceed score', () {
        final score = ScoreCalculator.monthlyScore(
          dailyScores: [0.1],
          totalDeductions: 10, // 50% penalty
        );
        expect(score, 0.0);
      });

      test('returns 0.0 for empty daily scores', () {
        expect(
          ScoreCalculator.monthlyScore(
              dailyScores: [], totalDeductions: 0),
          0.0,
        );
      });

      test('clamps to max 1.0', () {
        final score = ScoreCalculator.monthlyScore(
          dailyScores: [1.0, 1.0, 1.0],
          totalDeductions: 0,
        );
        expect(score, lessThanOrEqualTo(1.0));
      });
    });

    // ── scoreToLevel ─────────────────────────────────────────
    group('scoreToLevel', () {
      test('maps scores to correct levels', () {
        expect(ScoreCalculator.scoreToLevel(0.0), 1);
        expect(ScoreCalculator.scoreToLevel(0.40), 1);
        expect(ScoreCalculator.scoreToLevel(0.50), 2);
        expect(ScoreCalculator.scoreToLevel(0.64), 2);
        expect(ScoreCalculator.scoreToLevel(0.65), 3);
        expect(ScoreCalculator.scoreToLevel(0.79), 3);
        expect(ScoreCalculator.scoreToLevel(0.80), 4);
        expect(ScoreCalculator.scoreToLevel(0.94), 4);
        expect(ScoreCalculator.scoreToLevel(0.95), 5);
        expect(ScoreCalculator.scoreToLevel(1.0), 5);
      });
    });

    // ── shouldHoldLevel ──────────────────────────────────────
    group('shouldHoldLevel', () {
      test('holds when drop exceeds 20%', () {
        expect(
          ScoreCalculator.shouldHoldLevel(
              previousScore: 0.90, currentScore: 0.65),
          isTrue,
        );
      });

      test('does not hold for drop of exactly 20%', () {
        expect(
          ScoreCalculator.shouldHoldLevel(
              previousScore: 0.90, currentScore: 0.70),
          isFalse,
        );
      });

      test('does not hold for small drop', () {
        expect(
          ScoreCalculator.shouldHoldLevel(
              previousScore: 0.80, currentScore: 0.75),
          isFalse,
        );
      });
    });

    // ── resolveLevel ─────────────────────────────────────────
    group('resolveLevel', () {
      test('promotes when score warrants it and no hold', () {
        final level = ScoreCalculator.resolveLevel(
          currentScore: 0.85, // level 4
          levelBefore: 3,
          previousMonthScore: 0.80,
        );
        expect(level, 4);
      });

      test('holds level when drop > 20%', () {
        final level = ScoreCalculator.resolveLevel(
          currentScore: 0.50, // would be level 2
          levelBefore: 4,
          previousMonthScore: 0.85,
        );
        expect(level, 4); // held at 4
      });

      test('promotes freely when no previous month', () {
        final level = ScoreCalculator.resolveLevel(
          currentScore: 0.95,
          levelBefore: 1,
          previousMonthScore: null,
        );
        expect(level, 5);
      });
    });

    // ── completedIdsFromRecords ──────────────────────────────
    group('completedIdsFromRecords', () {
      test('returns only completed habit IDs', () {
        final records = [
          _record('kid1', 'h1', completed: true),
          _record('kid1', 'h2', completed: false),
          _record('kid1', 'h3', completed: true),
        ];
        final ids = ScoreCalculator.completedIdsFromRecords(records);
        expect(ids, {'h1', 'h3'});
        expect(ids, isNot(contains('h2')));
      });

      test('returns empty set when all incomplete', () {
        final records = [
          _record('kid1', 'h1', completed: false),
        ];
        expect(ScoreCalculator.completedIdsFromRecords(records), isEmpty);
      });
    });

    // ── toPercent ────────────────────────────────────────────
    group('toPercent', () {
      test('formats 0.87 as 87%', () {
        expect(ScoreCalculator.toPercent(0.87), '87%');
      });
      test('formats 1.0 as 100%', () {
        expect(ScoreCalculator.toPercent(1.0), '100%');
      });
      test('formats 0.0 as 0%', () {
        expect(ScoreCalculator.toPercent(0.0), '0%');
      });
    });
  });
}
