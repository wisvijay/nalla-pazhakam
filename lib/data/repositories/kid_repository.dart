import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/kid_model.dart';
import '../../core/constants/app_constants.dart';

/// Provider — screens access kids via: ref.watch(kidRepositoryProvider)
final kidRepositoryProvider = Provider<KidRepository>((ref) {
  return KidRepository();
});

class KidRepository {
  Box<KidModel> get _box => Hive.box<KidModel>(AppConstants.kidsBox);

  // ── Read ─────────────────────────────────────────────────────
  List<KidModel> getAll() {
    return _box.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  KidModel? getById(String id) => _box.get(id);

  bool get isEmpty => _box.isEmpty;

  // ── Write ────────────────────────────────────────────────────
  Future<void> save(KidModel kid) async {
    await _box.put(kid.id, kid);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  // ── Level update ─────────────────────────────────────────────
  Future<void> updateLevel(String kidId, int newLevel) async {
    final kid = getById(kidId);
    if (kid == null) return;
    final updated = kid.copyWith(currentLevel: newLevel);
    await _box.put(kidId, updated);
  }

  // ── Watch (reactive stream for UI) ──────────────────────────
  /// Emits current state immediately, then re-emits on every box change.
  /// Using async* so the first value arrives even when the box is empty.
  Stream<List<KidModel>> watchAll() async* {
    yield getAll(); // emit current snapshot right away
    yield* _box.watch().map((_) => getAll());
  }
}

/// Reactive provider — rebuilds widgets when the kids box changes
final kidsStreamProvider = StreamProvider<List<KidModel>>((ref) {
  final repo = ref.watch(kidRepositoryProvider);
  return repo.watchAll();
});

/// Synchronous list (for non-reactive reads)
final kidsListProvider = Provider<List<KidModel>>((ref) {
  ref.watch(kidsStreamProvider); // invalidate when box changes
  return ref.read(kidRepositoryProvider).getAll();
});
