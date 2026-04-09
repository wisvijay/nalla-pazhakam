import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/kid_model.dart';
import '../../data/repositories/achievement_repository.dart';
import '../providers/group_provider.dart';

/// Pushes local scores to Firestore so the group leaderboard stays current.
/// All methods are fire-and-forget — they never block the UI.
class SyncService {
  static final _db = FirebaseFirestore.instance;

  // ── Sync all of a user's kids to Firestore ───────────────────────────────
  static Future<void> syncAllKids({
    required List<KidModel> kids,
    required String userId,
    required String groupId,
    required AchievementRepository achievementRepo,
  }) async {
    final weekKey = weekKeyFor(DateTime.now());
    final futures = kids.map((kid) => _syncKid(
          kid: kid,
          userId: userId,
          groupId: groupId,
          weekKey: weekKey,
          achievementRepo: achievementRepo,
        ));
    await Future.wait(futures, eagerError: false);
  }

  static Future<void> _syncKid({
    required KidModel kid,
    required String userId,
    required String groupId,
    required String weekKey,
    required AchievementRepository achievementRepo,
  }) async {
    try {
      // Get this week's achievement from local Hive
      final achievement = achievementRepo.getWeekly(kid.id, DateTime.now());

      final stars        = achievement?.starsEarned        ?? 0;
      final scorePercent = achievement?.completionPercentage ?? 0.0;

      // Write / merge weekly score document
      final scoreDocId = '${kid.id}_$weekKey';
      await _db.collection('weeklyScores').doc(scoreDocId).set({
        'kidId':        kid.id,
        'kidName':      kid.name,
        'ownerId':      userId,
        'groupId':      groupId,
        'weekKey':      weekKey,
        'stars':        stars,
        'scorePercent': scorePercent,
        'currentLevel': kid.currentLevel,
        'updatedAt':    FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Keep public kid profile in sync (name + level only — no private data)
      await _db.collection('publicKids').doc(kid.id).set({
        'name':         kid.name,
        'ownerId':      userId,
        'groupId':      groupId,
        'currentLevel': kid.currentLevel,
        'updatedAt':    FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('SyncService: failed to sync kid ${kid.id}: $e');
    }
  }
}
