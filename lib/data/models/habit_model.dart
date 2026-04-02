import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

part 'habit_model.g.dart';

@HiveType(typeId: AppConstants.habitTypeId)
class HabitModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String description;

  /// Default emoji icon (always present)
  @HiveField(3)
  late String emojiIcon;

  /// Optional custom image (base64) — replaces emoji when set
  @HiveField(4)
  String? imageBase64;

  /// true = good habit (adds to score), false = negative behaviour (deducts)
  @HiveField(5)
  late bool isPositive;

  /// Whether this habit appears in the daily tracker
  @HiveField(6)
  late bool isActive;

  /// Display order in the list
  @HiveField(7)
  late int sortOrder;

  /// Distinguishes pre-loaded defaults from user-created habits
  @HiveField(8)
  late bool isDefault;

  HabitModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emojiIcon,
    this.imageBase64,
    required this.isPositive,
    this.isActive = true,
    required this.sortOrder,
    this.isDefault = false,
  });

  HabitModel copyWith({
    String? id,
    String? name,
    String? description,
    String? emojiIcon,
    String? imageBase64,
    bool clearImage = false,
    bool? isPositive,
    bool? isActive,
    int? sortOrder,
    bool? isDefault,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emojiIcon: emojiIcon ?? this.emojiIcon,
      imageBase64: clearImage ? null : (imageBase64 ?? this.imageBase64),
      isPositive: isPositive ?? this.isPositive,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() =>
      'HabitModel(id: $id, name: $name, positive: $isPositive)';
}
