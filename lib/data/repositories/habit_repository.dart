import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';
import '../../core/constants/app_constants.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

class HabitRepository {
  Box<HabitModel> get _box => Hive.box<HabitModel>(AppConstants.habitsBox);

  // ── Read ─────────────────────────────────────────────────────
  List<HabitModel> getAll() {
    return _box.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<HabitModel> getActive() =>
      getAll().where((h) => h.isActive).toList();

  List<HabitModel> getPositive({bool activeOnly = true}) => getAll()
      .where((h) => h.isPositive && (!activeOnly || h.isActive))
      .toList();

  List<HabitModel> getNegative({bool activeOnly = true}) => getAll()
      .where((h) => !h.isPositive && (!activeOnly || h.isActive))
      .toList();

  HabitModel? getById(String id) => _box.get(id);

  bool get isEmpty => _box.isEmpty;

  // ── Write ────────────────────────────────────────────────────
  Future<void> save(HabitModel habit) async {
    await _box.put(habit.id, habit);
  }

  Future<void> saveAll(List<HabitModel> habits) async {
    final map = {for (final h in habits) h.id: h};
    await _box.putAll(map);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleActive(String id) async {
    final habit = getById(id);
    if (habit == null) return;
    await _box.put(id, habit.copyWith(isActive: !habit.isActive));
  }

  // ── Watch ────────────────────────────────────────────────────
  /// Emits current state immediately, then re-emits on every box change.
  Stream<List<HabitModel>> watchAll() async* {
    yield getAll(); // emit current snapshot right away
    yield* _box.watch().map((_) => getAll());
  }
}

final habitsStreamProvider = StreamProvider<List<HabitModel>>((ref) {
  return ref.watch(habitRepositoryProvider).watchAll();
});

final activeHabitsProvider = Provider<List<HabitModel>>((ref) {
  ref.watch(habitsStreamProvider);
  return ref.read(habitRepositoryProvider).getActive();
});

final positiveHabitsProvider = Provider<List<HabitModel>>((ref) {
  ref.watch(habitsStreamProvider);
  return ref.read(habitRepositoryProvider).getPositive();
});

final negativeHabitsProvider = Provider<List<HabitModel>>((ref) {
  ref.watch(habitsStreamProvider);
  return ref.read(habitRepositoryProvider).getNegative();
});
