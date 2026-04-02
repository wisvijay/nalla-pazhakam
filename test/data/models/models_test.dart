import 'package:flutter_test/flutter_test.dart';
import 'package:nalla_pazhakam/data/models/kid_model.dart';
import 'package:nalla_pazhakam/data/models/habit_model.dart';
import 'package:nalla_pazhakam/data/models/daily_record_model.dart';
import 'package:nalla_pazhakam/data/models/weekly_achievement_model.dart';
import 'package:nalla_pazhakam/data/models/monthly_report_model.dart';

// ── Helpers ────────────────────────────────────────────────────────
KidModel _kid({int levelOffset = 0}) => KidModel(
      id: 'kid_001',
      name: 'Arjun',
      dob: DateTime(2018, 5, 15),
      favFood: 'Dosa',
      favSnacks: 'Murukku',
      favFruits: 'Mango',
      currentLevel: 1 + levelOffset,
      createdAt: DateTime(2026, 1, 1),
    );

HabitModel _habit({bool positive = true}) => HabitModel(
      id: 'habit_brush',
      name: 'Brush Teeth',
      description: 'Morning and night',
      emojiIcon: '🦷',
      isPositive: positive,
      isActive: true,
      sortOrder: 0,
      isDefault: true,
    );

void main() {
  // ── KidModel ───────────────────────────────────────────────
  group('KidModel', () {
    test('age computed correctly', () {
      final kid = _kid();
      // born 2018-05-15; as of 2026 they should be 7 (before May 15) or 8
      final age = kid.age;
      expect(age, inInclusiveRange(7, 8));
    });

    test('copyWith preserves unchanged fields', () {
      final original = _kid();
      final updated = original.copyWith(name: 'Priya');
      expect(updated.name, 'Priya');
      expect(updated.id, original.id);
      expect(updated.dob, original.dob);
      expect(updated.currentLevel, original.currentLevel);
    });

    test('copyWith updates level', () {
      final kid = _kid();
      final promoted = kid.copyWith(currentLevel: 3);
      expect(promoted.currentLevel, 3);
    });

    test('copyWith clearPhoto removes photo', () {
      final kid = _kid()..photoBase64 = 'base64data';
      final cleared = kid.copyWith(clearPhoto: true);
      expect(cleared.photoBase64, isNull);
    });

    test('toString contains name and level', () {
      final kid = _kid();
      expect(kid.toString(), contains('Arjun'));
      expect(kid.toString(), contains('level: 1'));
    });
  });

  // ── HabitModel ─────────────────────────────────────────────
  group('HabitModel', () {
    test('creates with correct defaults', () {
      final habit = _habit();
      expect(habit.isActive, isTrue);
      expect(habit.isDefault, isTrue);
      expect(habit.imageBase64, isNull);
    });

    test('copyWith toggles isActive', () {
      final habit = _habit();
      final toggled = habit.copyWith(isActive: false);
      expect(toggled.isActive, isFalse);
      expect(toggled.name, habit.name); // unchanged
    });

    test('copyWith clearImage removes image', () {
      final habit = _habit()..imageBase64 = 'img_data';
      final cleared = habit.copyWith(clearImage: true);
      expect(cleared.imageBase64, isNull);
    });

    test('negative habit has isPositive false', () {
      final neg = _habit(positive: false);
      expect(neg.isPositive, isFalse);
    });
  });

  // ── DailyRecordModel ───────────────────────────────────────
  group('DailyRecordModel', () {
    test('factory creates correct composite ID', () {
      final record = DailyRecordModel.create(
        kidId: 'kid_001',
        habitId: 'habit_brush',
        date: DateTime(2026, 4, 1),
        completed: true,
      );
      expect(record.id, 'kid_001_habit_brush_2026-04-01');
    });

    test('factory stores date as midnight', () {
      final record = DailyRecordModel.create(
        kidId: 'k',
        habitId: 'h',
        date: DateTime(2026, 4, 1, 14, 30), // afternoon
        completed: true,
      );
      expect(record.date.hour, 0);
      expect(record.date.minute, 0);
    });

    test('copyWith toggles completed', () {
      final record = DailyRecordModel.create(
        kidId: 'kid_001',
        habitId: 'h',
        date: DateTime(2026, 4, 1),
        completed: true,
      );
      final toggled = record.copyWith(completed: false);
      expect(toggled.completed, isFalse);
      expect(toggled.id, record.id); // id unchanged
    });

    test('pads single-digit month and day in ID', () {
      final record = DailyRecordModel.create(
        kidId: 'k',
        habitId: 'h',
        date: DateTime(2026, 1, 9),
        completed: false,
      );
      expect(record.id, 'k_h_2026-01-09');
    });
  });

  // ── WeeklyAchievementModel ─────────────────────────────────
  group('WeeklyAchievementModel', () {
    test('weekEnd is 6 days after weekStart', () {
      final monday = DateTime(2026, 3, 30);
      final weekly = WeeklyAchievementModel(
        id: 'test',
        kidId: 'k',
        weekStart: monday,
        starsEarned: 5,
        completionPercentage: 0.82,
        totalDeductions: 1,
        isFinalized: false,
      );
      expect(weekly.weekEnd, DateTime(2026, 4, 5)); // Sunday
    });

    test('copyWith updates stars without touching other fields', () {
      final w = WeeklyAchievementModel(
        id: 'w1',
        kidId: 'k1',
        weekStart: DateTime(2026, 3, 30),
        starsEarned: 3,
        completionPercentage: 0.65,
        totalDeductions: 2,
        isFinalized: false,
      );
      final updated = w.copyWith(starsEarned: 7, isFinalized: true);
      expect(updated.starsEarned, 7);
      expect(updated.isFinalized, isTrue);
      expect(updated.kidId, w.kidId);
      expect(updated.completionPercentage, w.completionPercentage);
    });
  });

  // ── MonthlyReportModel ─────────────────────────────────────
  group('MonthlyReportModel', () {
    test('monthKey formats correctly', () {
      final report = MonthlyReportModel(
        id: 'r1',
        kidId: 'k',
        month: 4,
        year: 2026,
        finalScore: 0.87,
        levelBefore: 3,
        levelAfter: 4,
        promoted: true,
        totalStars: 18,
        totalDeductions: 2,
        generatedAt: DateTime(2026, 5, 1),
      );
      expect(report.monthKey, '2026-04');
    });

    test('scorePercent formats correctly', () {
      final report = MonthlyReportModel(
        id: 'r2',
        kidId: 'k',
        month: 3,
        year: 2026,
        finalScore: 0.923,
        levelBefore: 4,
        levelAfter: 5,
        promoted: true,
        totalStars: 24,
        totalDeductions: 0,
        generatedAt: DateTime.now(),
      );
      expect(report.scorePercent, '92%');
    });

    test('promoted is true when levelAfter > levelBefore', () {
      final report = MonthlyReportModel(
        id: 'r3',
        kidId: 'k',
        month: 2,
        year: 2026,
        finalScore: 0.82,
        levelBefore: 2,
        levelAfter: 3,
        promoted: true,
        totalStars: 16,
        totalDeductions: 1,
        generatedAt: DateTime.now(),
      );
      expect(report.promoted, isTrue);
      expect(report.levelAfter > report.levelBefore, isTrue);
    });
  });
}
