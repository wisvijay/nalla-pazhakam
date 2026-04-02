import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

part 'daily_record_model.g.dart';

@HiveType(typeId: AppConstants.dailyRecordTypeId)
class DailyRecordModel extends HiveObject {
  /// Composite key: "{kidId}_{habitId}_{YYYY-MM-DD}"
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String kidId;

  @HiveField(2)
  late String habitId;

  /// Stored as midnight of the given day for consistent comparison
  @HiveField(3)
  late DateTime date;

  /// Whether the habit was completed (positive) or the behaviour occurred (negative)
  @HiveField(4)
  late bool completed;

  /// Optional parent note for the day
  @HiveField(5)
  String? notes;

  DailyRecordModel({
    required this.id,
    required this.kidId,
    required this.habitId,
    required this.date,
    required this.completed,
    this.notes,
  });

  /// Factory — builds the composite id automatically
  factory DailyRecordModel.create({
    required String kidId,
    required String habitId,
    required DateTime date,
    required bool completed,
    String? notes,
  }) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return DailyRecordModel(
      id: '${kidId}_${habitId}_$dateStr',
      kidId: kidId,
      habitId: habitId,
      date: DateTime(date.year, date.month, date.day), // midnight only
      completed: completed,
      notes: notes,
    );
  }

  DailyRecordModel copyWith({bool? completed, String? notes}) {
    return DailyRecordModel(
      id: id,
      kidId: kidId,
      habitId: habitId,
      date: date,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'DailyRecord(kidId: $kidId, habitId: $habitId, date: $date, done: $completed)';
}
