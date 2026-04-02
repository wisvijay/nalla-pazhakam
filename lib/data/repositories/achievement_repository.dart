import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/weekly_achievement_model.dart';
import '../models/monthly_report_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';

final achievementRepositoryProvider =
    Provider<AchievementRepository>((ref) => AchievementRepository());

class AchievementRepository {
  Box<WeeklyAchievementModel> get _weeklyBox =>
      Hive.box<WeeklyAchievementModel>(AppConstants.weeklyAchievementsBox);

  Box<MonthlyReportModel> get _monthlyBox =>
      Hive.box<MonthlyReportModel>(AppConstants.monthlyReportsBox);

  // ── Weekly ───────────────────────────────────────────────────

  WeeklyAchievementModel? getWeekly(String kidId, DateTime anyDayInWeek) {
    final id = _weeklyId(kidId, anyDayInWeek);
    return _weeklyBox.get(id);
  }

  List<WeeklyAchievementModel> getAllWeeklyForKid(String kidId) {
    return _weeklyBox.values
        .where((w) => w.kidId == kidId)
        .toList()
      ..sort((a, b) => a.weekStart.compareTo(b.weekStart));
  }

  Future<void> saveWeekly(WeeklyAchievementModel achievement) async {
    await _weeklyBox.put(achievement.id, achievement);
  }

  /// Create or update the weekly record for the given week
  Future<WeeklyAchievementModel> upsertWeekly({
    required String kidId,
    required DateTime weekStart,
    required int starsEarned,
    required double completionPercentage,
    required int totalDeductions,
    bool isFinalized = false,
  }) async {
    final id = _weeklyId(kidId, weekStart);
    final record = WeeklyAchievementModel(
      id: id,
      kidId: kidId,
      weekStart: NallaDateUtils.weekStart(weekStart),
      starsEarned: starsEarned,
      completionPercentage: completionPercentage,
      totalDeductions: totalDeductions,
      isFinalized: isFinalized,
    );
    await _weeklyBox.put(id, record);
    return record;
  }

  // ── Monthly ──────────────────────────────────────────────────

  MonthlyReportModel? getMonthly(String kidId, int year, int month) {
    final id = _monthlyId(kidId, year, month);
    return _monthlyBox.get(id);
  }

  List<MonthlyReportModel> getAllMonthlyForKid(String kidId) {
    return _monthlyBox.values
        .where((m) => m.kidId == kidId)
        .toList()
      ..sort((a, b) {
        final aDate = DateTime(a.year, a.month);
        final bDate = DateTime(b.year, b.month);
        return aDate.compareTo(bDate);
      });
  }

  Future<void> saveMonthly(MonthlyReportModel report) async {
    await _monthlyBox.put(report.id, report);
  }

  // ── Watch ────────────────────────────────────────────────────
  Stream<WeeklyAchievementModel?> watchWeek(
      String kidId, DateTime anyDayInWeek) async* {
    yield getWeekly(kidId, anyDayInWeek);
    yield* _weeklyBox.watch().map((_) => getWeekly(kidId, anyDayInWeek));
  }

  Stream<List<MonthlyReportModel>> watchMonthlyHistory(String kidId) async* {
    yield getAllMonthlyForKid(kidId);
    yield* _monthlyBox.watch().map((_) => getAllMonthlyForKid(kidId));
  }

  // ── ID builders ──────────────────────────────────────────────
  String _weeklyId(String kidId, DateTime date) {
    final ws = NallaDateUtils.weekStart(date);
    return '${kidId}_${NallaDateUtils.weekKey(ws)}';
  }

  String _monthlyId(String kidId, int year, int month) {
    return '${kidId}_$year-${month.toString().padLeft(2, '0')}';
  }
}
