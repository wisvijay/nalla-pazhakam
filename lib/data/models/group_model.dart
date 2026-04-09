import 'package:cloud_firestore/cloud_firestore.dart';

/// A shared group that links multiple families together.
class GroupModel {
  final String id;
  final String name;
  final String joinCode;   // 6-char, e.g. "ABC123"
  final String createdBy;  // userId of creator
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    required this.joinCode,
    required this.createdBy,
    required this.createdAt,
  });

  factory GroupModel.fromMap(String id, Map<String, dynamic> map) {
    return GroupModel(
      id: id,
      name: map['name'] as String? ?? '',
      joinCode: map['joinCode'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'joinCode': joinCode,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

/// One kid's score entry shown on the leaderboard.
class WeeklyScoreEntry {
  final String kidId;
  final String kidName;
  final String ownerId;
  final String groupId;
  final String weekKey;   // e.g. "2025-W15"
  final int stars;          // 0–7
  final double scorePercent; // 0.0–1.0
  final int currentLevel;   // 1–5
  final DateTime updatedAt;

  const WeeklyScoreEntry({
    required this.kidId,
    required this.kidName,
    required this.ownerId,
    required this.groupId,
    required this.weekKey,
    required this.stars,
    required this.scorePercent,
    required this.currentLevel,
    required this.updatedAt,
  });

  factory WeeklyScoreEntry.fromMap(Map<String, dynamic> map) {
    return WeeklyScoreEntry(
      kidId:        map['kidId']         as String? ?? '',
      kidName:      map['kidName']       as String? ?? '',
      ownerId:      map['ownerId']       as String? ?? '',
      groupId:      map['groupId']       as String? ?? '',
      weekKey:      map['weekKey']       as String? ?? '',
      stars:        (map['stars']        as num?)?.toInt() ?? 0,
      scorePercent: (map['scorePercent'] as num?)?.toDouble() ?? 0.0,
      currentLevel: (map['currentLevel'] as num?)?.toInt() ?? 1,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'kidId':        kidId,
    'kidName':      kidName,
    'ownerId':      ownerId,
    'groupId':      groupId,
    'weekKey':      weekKey,
    'stars':        stars,
    'scorePercent': scorePercent,
    'currentLevel': currentLevel,
    'updatedAt':    FieldValue.serverTimestamp(),
  };
}
