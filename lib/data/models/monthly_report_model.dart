import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

part 'monthly_report_model.g.dart';

@HiveType(typeId: AppConstants.monthlyReportTypeId)
class MonthlyReportModel extends HiveObject {
  /// Composite key: "{kidId}_{YYYY}-{MM}"
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String kidId;

  @HiveField(2)
  late int month; // 1–12

  @HiveField(3)
  late int year;

  /// Final monthly score 0.0–1.0 (after deductions)
  @HiveField(4)
  late double finalScore;

  /// Level at the start of the month (1–5)
  @HiveField(5)
  late int levelBefore;

  /// Level after evaluation (1–5)
  @HiveField(6)
  late int levelAfter;

  /// Whether the child was promoted to a higher level
  @HiveField(7)
  late bool promoted;

  /// Total stars earned across all weeks of the month
  @HiveField(8)
  late int totalStars;

  /// Total negative deductions for the month
  @HiveField(9)
  late int totalDeductions;

  /// When the report was generated
  @HiveField(10)
  late DateTime generatedAt;

  MonthlyReportModel({
    required this.id,
    required this.kidId,
    required this.month,
    required this.year,
    required this.finalScore,
    required this.levelBefore,
    required this.levelAfter,
    required this.promoted,
    required this.totalStars,
    required this.totalDeductions,
    required this.generatedAt,
  });

  String get monthKey =>
      '$year-${month.toString().padLeft(2, '0')}';

  String get scorePercent =>
      '${(finalScore * 100).toStringAsFixed(0)}%';

  @override
  String toString() =>
      'MonthlyReport(kidId: $kidId, month: $monthKey, score: $scorePercent, level: $levelBefore→$levelAfter)';
}
