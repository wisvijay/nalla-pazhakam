import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';
import 'auth_provider.dart';

// ── Current user's group (loaded once on auth change) ─────────────────────
final userGroupProvider = FutureProvider<GroupModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final repo = ref.watch(groupRepositoryProvider);
  return repo.getUserGroup(user.uid);
});

// ── Leaderboard stream for current group + week ────────────────────────────
final leaderboardProvider =
    StreamProvider.autoDispose<List<WeeklyScoreEntry>>((ref) {
  final groupAsync = ref.watch(userGroupProvider);
  final group = groupAsync.valueOrNull;
  if (group == null) return const Stream.empty();

  final weekKey = _currentWeekKey();
  return ref.watch(groupRepositoryProvider).watchLeaderboard(group.id, weekKey);
});

// ── Compute ISO week key  e.g. "2025-W15" ─────────────────────────────────
String _currentWeekKey() {
  return weekKeyFor(DateTime.now());
}

String weekKeyFor(DateTime date) {
  // Find the Thursday of the week (ISO 8601: week belongs to the year that owns its Thursday)
  final thursday = date.subtract(Duration(days: date.weekday - 4));
  final startOfYear = DateTime(thursday.year, 1, 1);
  final weekNum = ((thursday.difference(startOfYear).inDays) ~/ 7) + 1;
  return '${thursday.year}-W${weekNum.toString().padLeft(2, '0')}';
}
