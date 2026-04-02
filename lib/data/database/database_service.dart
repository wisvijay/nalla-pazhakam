import 'package:hive_flutter/hive_flutter.dart';
import '../models/kid_model.dart';
import '../models/habit_model.dart';
import '../models/daily_record_model.dart';
import '../models/weekly_achievement_model.dart';
import '../models/monthly_report_model.dart';
import '../../core/constants/app_constants.dart';

/// Initialises Hive, registers all TypeAdapters, opens all boxes,
/// and seeds the default habits list on first launch.
///
/// On web this uses IndexedDB automatically.
/// On mobile it uses the app's documents directory.
class DatabaseService {
  DatabaseService._();

  static bool _initialised = false;

  static Future<void> init() async {
    if (_initialised) return;

    // ── 1. Register TypeAdapters ────────────────────────────────
    if (!Hive.isAdapterRegistered(AppConstants.kidTypeId)) {
      Hive.registerAdapter(KidModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.habitTypeId)) {
      Hive.registerAdapter(HabitModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.dailyRecordTypeId)) {
      Hive.registerAdapter(DailyRecordModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.weeklyAchievementTypeId)) {
      Hive.registerAdapter(WeeklyAchievementModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.monthlyReportTypeId)) {
      Hive.registerAdapter(MonthlyReportModelAdapter());
    }

    // ── 2. Open all boxes ───────────────────────────────────────
    await Future.wait([
      Hive.openBox<KidModel>(AppConstants.kidsBox),
      Hive.openBox<HabitModel>(AppConstants.habitsBox),
      Hive.openBox<DailyRecordModel>(AppConstants.dailyRecordsBox),
      Hive.openBox<WeeklyAchievementModel>(
          AppConstants.weeklyAchievementsBox),
      Hive.openBox<MonthlyReportModel>(AppConstants.monthlyReportsBox),
      Hive.openBox(AppConstants.settingsBox),
    ]);

    // ── 3. Seed default habits (only on first launch) ───────────
    await _seedDefaultHabits();

    _initialised = true;
  }

  static Future<void> _seedDefaultHabits() async {
    final box = Hive.box<HabitModel>(AppConstants.habitsBox);
    if (box.isNotEmpty) return; // already seeded

    final habits = AppConstants.defaultHabits.map((data) {
      return HabitModel(
        id: 'default_${data['name'].toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
        name: data['name'] as String,
        description: data['description'] as String,
        emojiIcon: data['emoji'] as String,
        isPositive: data['isPositive'] as bool,
        isActive: true,
        sortOrder: data['sortOrder'] as int,
        isDefault: true,
      );
    }).toList();

    final map = {for (final h in habits) h.id: h};
    await box.putAll(map);
  }

  /// Wipe all data (useful for testing / reset feature)
  static Future<void> clearAll() async {
    await Future.wait([
      Hive.box<KidModel>(AppConstants.kidsBox).clear(),
      Hive.box<HabitModel>(AppConstants.habitsBox).clear(),
      Hive.box<DailyRecordModel>(AppConstants.dailyRecordsBox).clear(),
      Hive.box<WeeklyAchievementModel>(
              AppConstants.weeklyAchievementsBox)
          .clear(),
      Hive.box<MonthlyReportModel>(AppConstants.monthlyReportsBox).clear(),
    ]);
    // Re-seed habits after clear
    await _seedDefaultHabits();
  }
}
