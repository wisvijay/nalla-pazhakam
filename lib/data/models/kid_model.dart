import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

part 'kid_model.g.dart';

@HiveType(typeId: AppConstants.kidTypeId)
class KidModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late DateTime dob;

  /// Base64-encoded image string — works on both web (IndexedDB) and mobile
  @HiveField(3)
  String? photoBase64;

  @HiveField(4)
  late String favFood;

  @HiveField(5)
  late String favSnacks;

  @HiveField(6)
  late String favFruits;

  /// 1 = Seedling … 5 = Habit Champion
  @HiveField(7)
  late int currentLevel;

  @HiveField(8)
  late DateTime createdAt;

  KidModel({
    required this.id,
    required this.name,
    required this.dob,
    this.photoBase64,
    required this.favFood,
    required this.favSnacks,
    required this.favFruits,
    this.currentLevel = 1,
    required this.createdAt,
  });

  /// Age in whole years
  int get age {
    final now = DateTime.now();
    int years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  KidModel copyWith({
    String? id,
    String? name,
    DateTime? dob,
    String? photoBase64,
    bool clearPhoto = false,
    String? favFood,
    String? favSnacks,
    String? favFruits,
    int? currentLevel,
    DateTime? createdAt,
  }) {
    return KidModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dob: dob ?? this.dob,
      photoBase64: clearPhoto ? null : (photoBase64 ?? this.photoBase64),
      favFood: favFood ?? this.favFood,
      favSnacks: favSnacks ?? this.favSnacks,
      favFruits: favFruits ?? this.favFruits,
      currentLevel: currentLevel ?? this.currentLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'KidModel(id: $id, name: $name, level: $currentLevel)';
}
