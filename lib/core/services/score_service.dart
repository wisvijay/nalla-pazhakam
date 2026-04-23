import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/weekly_achievement_model.dart';
import '../../data/models/monthly_report_model.dart';
import '../../data/repositories/daily_record_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../data/repositories/kid_repository.dart';
import '../utils/date_utils.dart';
import 'score_calculator.dart';

final scoreServiceProvider = Provider<ScoreService>((ref) {
  return ScoreService(
    dailyRepo: ref.watch(dailyRecordRepositoryProvider),
    habitRepo: ref.watch(habitRepositoryProvider),
    achievementRepo: ref.watch(achievementRepositoryProvider),
    kidRepo: ref.watch(kidRepositoryProvider),
  );
});

class ScoreService {
  final DailyRecordRepository dailyRepo;
  final HabitRepository habitRepo;
  final AchievementRepository achievementRepo;
  final KidRepository kidRepo;

  ScoreService({
    required this.dailyRepo,
    required this.habitRepo,
    required this.achievementRepo,
    required this.kidRepo,
  });

  // ── Daily ─────────────────────────────────────────────────────

  double getDailyScore(String kidId, DateTime date) {
    final positiveHabits = habitRepo.getPositive();
    final records = dailyRepo.getForDay(kidId, date);
    final completedIds = ScoreCalculator.completedIdsFromRecords(records);
    return ScoreCalculator.dailyScore(
      positiveHabits: positiveHabits,
      completedIds: completedIds,
    );
  }

  int getDailyDeductions(String kidId, DateTime date) {
    final negativeHabits = habitRepo.getNegative();
    final records = dailyRepo.getForDay(kidId, date);
    final completedIds = ScoreCalculator.completedIdsFromRecords(records);
    return ScoreCalculator.dailyDeductions(
      negativeHabits: negativeHabits,
      completedIds: completedIds,
    );
  }

  bool didEarnStarForDay(String kidId, DateTime date) =>
      ScoreCalculator.earnedStar(getDailyScore(kidId, date));

  // ── Weekly ────────────────────────────────────────────────────

  WeeklyStats getWeeklyStats(String kidId, DateTime anyDayInWeek) {
    final days = NallaDateUtils.daysInWeek(anyDayInWeek);
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final dailyScores = <double>[];
    int totalDeductions = 0;

    for (final day in days) {
      if (day.isAfter(today)) break;
      dailyScores.add(getDailyScore(kidId, day));
      totalDeductions += getDailyDeductions(kidId, day);
    }

    return WeeklyStats(
      starsEarned: ScoreCalculator.weeklyStars(dailyScores),
      completionPercentage: ScoreCalculator.weeklyAverage(dailyScores),
      totalDeductions: totalDeductions,
      daysTracked: dailyScores.length,
      dailyScores: dailyScores,
    );
  }

  Future<WeeklyAchievementModel> computeAndSaveWeekly(
      String kidId, DateTime anyDayInWeek) async {
    final stats = getWeeklyStats(kidId, anyDayInWeek);
    final weekStart = NallaDateUtils.weekStart(anyDayInWeek);
    final isFinalized =
        DateTime.now().isAfter(NallaDateUtils.weekEnd(anyDayInWeek));
    return await achievementRepo.upsertWeekly(
      kidId: kidId,
      weekStart: weekStart,
      starsEarned: stats.starsEarned,
      completionPercentage: stats.completionPercentage,
      totalDeductions: stats.totalDeductions,
      isFinalized: isFinalized,
    );
  }

  // ── Monthly ───────────────────────────────────────────────────

  double getMonthlyScore(String kidId, int year, int month) {
    final days = NallaDateUtils.daysInMonth(DateTime(year, month));
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final dailyScores = <double>[];
    int totalDeductions = 0;

    for (final day in days) {
      if (day.isAfter(today)) break;
      dailyScores.add(getDailyScore(kidId, day));
      totalDeductions += getDailyDeductions(kidId, day);
    }

    return ScoreCalculator.monthlyScore(
      dailyScores: dailyScores,
      totalDeductions: totalDeductions,
    );
  }

  Future<MonthlyReportModel> computeAndSaveMonthly(
      String kidId, int year, int month) async {
    final kid = kidRepo.getById(kidId);
    if (kid == null) throw Exception('Kid not found: $kidId');

    final finalScore = getMonthlyScore(kidId, year, month);
    final levelBefore = kid.currentLevel;

    final prevReport = achievementRepo.getMonthly(
        kidId, month == 1 ? year - 1 : year, month == 1 ? 12 : month - 1);

    final levelAfter = ScoreCalculator.resolveLevel(
      currentScore: finalScore,
      levelBefore: levelBefore,
      previousMonthScore: prevReport?.finalScore,
    );

    // Aggregate weekly stars for the month
    int totalStars = 0;
    for (final week in _weeksInMonth(year, month)) {
      totalStars += achievementRepo.getWeekly(kidId, week)?.starsEarned ?? 0;
    }

    // Count monthly deductions
    final negHabitIds = habitRepo.getNegative().map((h) => h.id).toSet();
    final totalDeductions = dailyRepo
        .getForMonth(kidId, year, month)
        .where((r) => r.completed && negHabitIds.contains(r.habitId))
        .length;

    final id =
        '${kidId}_$year-${month.toString().padLeft(2, '0')}';
    final report = MonthlyReportModel(
      id: id,
      kidId: kidId,
      month: month,
      year: year,
      finalScore: finalScore,
      levelBefore: levelBefore,
      levelAfter: levelAfter,
      promoted: levelAfter > levelBefore,
      totalStars: totalStars,
      totalDeductions: totalDeductions,
      generatedAt: DateTime.now(),
    );

    await achievementRepo.saveMonthly(report);
    if (levelAfter != levelBefore) {
      await kidRepo.updateLevel(kidId, levelAfter);
    }
    return report;
  }

  List<DateTime> _weeksInMonth(int year, int month) {
    final seen = <String>{};
    return NallaDateUtils.daysInMonth(DateTime(year, month))
        .where((d) => seen.add(NallaDateUtils.weekKey(d)))
        .toList();
  }
}

/// Value object returned by weekly stats
class WeeklyStats {
  final int starsEarned;
  final double completionPercentage;
  final int totalDeductions;
  final int daysTracked;
  final List<double> dailyScores;

  const WeeklyStats({
    required this.starsEarned,
    required this.completionPercentage,
    required this.totalDeductions,
    required this.daysTracked,
    required this.dailyScores,
  });

  String get percentLabel => ScoreCalculator.toPercent(completionPercentage);
}
