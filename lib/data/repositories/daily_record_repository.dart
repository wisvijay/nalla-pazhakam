import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_record_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';

final dailyRecordRepositoryProvider = Provider<DailyRecordRepository>((ref) {
  return DailyRecordRepository();
});

class DailyRecordRepository {
  Box<DailyRecordModel> get _box =>
      Hive.box<DailyRecordModel>(AppConstants.dailyRecordsBox);

  // ── Read ─────────────────────────────────────────────────────

  /// All records for a kid on a specific day
  List<DailyRecordModel> getForDay(String kidId, DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    return _box.values
        .where((r) =>
            r.kidId == kidId && NallaDateUtils.isSameDay(r.date, dayStart))
        .toList();
  }

  /// Single record for a kid + habit + day (null if not yet marked)
  DailyRecordModel? getRecord(String kidId, String habitId, DateTime date) {
    final id = _buildId(kidId, habitId, date);
    return _box.get(id);
  }

  /// All records for a kid in a date range (inclusive)
  List<DailyRecordModel> getForRange(
      String kidId, DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    return _box.values
        .where((r) =>
            r.kidId == kidId &&
            !r.date.isBefore(start) &&
            !r.date.isAfter(end))
        .toList();
  }

  /// All records for a kid in a specific week
  List<DailyRecordModel> getForWeek(String kidId, DateTime anyDayInWeek) {
    final start = NallaDateUtils.weekStart(anyDayInWeek);
    final end = NallaDateUtils.weekEnd(anyDayInWeek);
    return getForRange(kidId, start, end);
  }

  /// All records for a kid in a specific month
  List<DailyRecordModel> getForMonth(String kidId, int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    return getForRange(kidId, start, end);
  }

  // ── Write ────────────────────────────────────────────────────

  /// Toggle a habit completed/not — creates record if missing
  Future<DailyRecordModel> toggle(
      String kidId, String habitId, DateTime date) async {
    final existing = getRecord(kidId, habitId, date);
    final record = existing != null
        ? existing.copyWith(completed: !existing.completed)
        : DailyRecordModel.create(
            kidId: kidId,
            habitId: habitId,
            date: date,
            completed: true,
          );
    await _box.put(record.id, record);
    return record;
  }

  /// Explicitly set completed state
  Future<void> setCompleted(
      String kidId, String habitId, DateTime date, bool completed) async {
    final existing = getRecord(kidId, habitId, date);
    final record = existing != null
        ? existing.copyWith(completed: completed)
        : DailyRecordModel.create(
            kidId: kidId,
            habitId: habitId,
            date: date,
            completed: completed,
          );
    await _box.put(record.id, record);
  }

  Future<void> delete(String id) async => await _box.delete(id);

  // ── Watch ────────────────────────────────────────────────────
  /// Emits current day's records immediately, then re-emits on any box change.
  Stream<List<DailyRecordModel>> watchDay(String kidId, DateTime date) async* {
    yield getForDay(kidId, date); // emit current snapshot right away
    yield* _box.watch().map((_) => getForDay(kidId, date));
  }

  // ── Helpers ──────────────────────────────────────────────────
  String _buildId(String kidId, String habitId, DateTime date) {
    final d = NallaDateUtils.dayKey(date);
    return '${kidId}_${habitId}_$d';
  }
}

/// Watch today's records for a specific kid — rebuilds on any change
final todayRecordsProvider =
    StreamProvider.family<List<DailyRecordModel>, String>((ref, kidId) {
  return ref
      .watch(dailyRecordRepositoryProvider)
      .watchDay(kidId, DateTime.now());
});
