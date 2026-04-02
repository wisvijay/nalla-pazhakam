import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

part 'weekly_achievement_model.g.dart';

@HiveType(typeId: AppConstants.weeklyAchievementTypeId)
class WeeklyAchievementModel extends HiveObject {
  /// Composite key: "{kidId}_{YYYY}-W{weekNum}"
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String kidId;

  /// Monday of the week
  @HiveField(2)
  late DateTime weekStart;

  /// 0–7 stars earned this week
  @HiveField(3)
  late int starsEarned;

  /// Average daily completion % across the week (0.0–1.0)
  @HiveField(4)
  late double completionPercentage;

  /// Total negative-behaviour occurrences for the week
  @HiveField(5)
  late int totalDeductions;

  /// true once Sunday has passed and the week is locked
  @HiveField(6)
  late bool isFinalized;

  WeeklyAchievementModel({
    required this.id,
    required this.kidId,
    required this.weekStart,
    this.starsEarned = 0,
    this.completionPercentage = 0.0,
    this.totalDeductions = 0,
    this.isFinalized = false,
  });

  /// Sunday of the week
  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  WeeklyAchievementModel copyWith({
    int? starsEarned,
    double? completionPercentage,
    int? totalDeductions,
    bool? isFinalized,
  }) {
    return WeeklyAchievementModel(
      id: id,
      kidId: kidId,
      weekStart: weekStart,
      starsEarned: starsEarned ?? this.starsEarned,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      isFinalized: isFinalized ?? this.isFinalized,
    );
  }

  @override
  String toString() =>
      'WeeklyAchievement(kidId: $kidId, week: $weekStart, stars: $starsEarned)';
}
