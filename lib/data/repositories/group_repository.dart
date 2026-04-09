import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group_model.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(FirebaseFirestore.instance);
});

class GroupRepository {
  final FirebaseFirestore _db;

  GroupRepository(this._db);

  // ── Create a new group ───────────────────────────────────────────────────
  Future<GroupModel> createGroup({
    required String name,
    required String userId,
    required String displayName,
  }) async {
    final code = await _uniqueCode();
    final ref  = _db.collection('groups').doc();

    final group = GroupModel(
      id: ref.id,
      name: name,
      joinCode: code,
      createdBy: userId,
      createdAt: DateTime.now(),
    );

    final batch = _db.batch();
    batch.set(ref, group.toMap());
    batch.set(
      _db.collection('groupMembers').doc('${ref.id}_$userId'),
      {
        'groupId': ref.id,
        'userId': userId,
        'displayName': displayName,
        'joinedAt': FieldValue.serverTimestamp(),
      },
    );
    batch.set(
      _db.collection('users').doc(userId),
      {'groupId': ref.id, 'displayName': displayName},
      SetOptions(merge: true),
    );
    await batch.commit();
    return group;
  }

  // ── Join an existing group by 6-char code ────────────────────────────────
  Future<GroupModel?> joinGroup({
    required String joinCode,
    required String userId,
    required String displayName,
  }) async {
    final snap = await _db
        .collection('groups')
        .where('joinCode', isEqualTo: joinCode.toUpperCase().trim())
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final doc   = snap.docs.first;
    final group = GroupModel.fromMap(doc.id, doc.data());

    final batch = _db.batch();
    batch.set(
      _db.collection('groupMembers').doc('${doc.id}_$userId'),
      {
        'groupId': doc.id,
        'userId': userId,
        'displayName': displayName,
        'joinedAt': FieldValue.serverTimestamp(),
      },
    );
    batch.set(
      _db.collection('users').doc(userId),
      {'groupId': doc.id, 'displayName': displayName},
      SetOptions(merge: true),
    );
    await batch.commit();
    return group;
  }

  // ── Get the group a user belongs to ─────────────────────────────────────
  Future<GroupModel?> getUserGroup(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    final groupId = userDoc.data()?['groupId'] as String?;
    if (groupId == null) return null;

    final groupDoc = await _db.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) return null;
    return GroupModel.fromMap(groupDoc.id, groupDoc.data()!);
  }

  // ── Real-time leaderboard for a group + week ─────────────────────────────
  Stream<List<WeeklyScoreEntry>> watchLeaderboard(
    String groupId,
    String weekKey,
  ) {
    return _db
        .collection('weeklyScores')
        .where('groupId', isEqualTo: groupId)
        .where('weekKey', isEqualTo: weekKey)
        .snapshots()
        .map((snap) {
      final entries = snap.docs
          .map((d) => WeeklyScoreEntry.fromMap(d.data()))
          .toList();
      entries.sort((a, b) {
        final sc = b.stars.compareTo(a.stars);
        if (sc != 0) return sc;
        return b.scorePercent.compareTo(a.scorePercent);
      });
      return entries;
    });
  }

  // ── Leave group ──────────────────────────────────────────────────────────
  Future<void> leaveGroup(String groupId, String userId) async {
    final batch = _db.batch();
    batch.delete(_db.collection('groupMembers').doc('${groupId}_$userId'));
    batch.update(_db.collection('users').doc(userId),
        {'groupId': FieldValue.delete()});
    await batch.commit();
  }

  // ── Generate unique 6-char alphanumeric join code ────────────────────────
  Future<String> _uniqueCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no I, O, 0, 1 (confusing)
    final rng   = Random.secure();
    while (true) {
      final code = String.fromCharCodes(
        List.generate(6, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
      );
      final existing = await _db
          .collection('groups')
          .where('joinCode', isEqualTo: code)
          .limit(1)
          .get();
      if (existing.docs.isEmpty) return code;
    }
  }
}
