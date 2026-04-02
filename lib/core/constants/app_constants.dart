/// App-wide constants for Nalla Pazhakam
abstract class AppConstants {
  // ── App Info ──────────────────────────────────────────────────
  static const String appName = 'Nalla Pazhakam';
  static const String appNameTamil = 'நல்ல பழக்கம்';
  static const String appTagline = 'Good Habits for Great Kids!';
  static const String appVersion = '1.0.0';

  // ── Hive Box Names ────────────────────────────────────────────
  static const String kidsBox = 'kids';
  static const String habitsBox = 'habits';
  static const String dailyRecordsBox = 'daily_records';
  static const String weeklyAchievementsBox = 'weekly_achievements';
  static const String monthlyReportsBox = 'monthly_reports';
  static const String settingsBox = 'settings';

  // ── Hive Type IDs ─────────────────────────────────────────────
  static const int kidTypeId = 0;
  static const int habitTypeId = 1;
  static const int dailyRecordTypeId = 2;
  static const int weeklyAchievementTypeId = 3;
  static const int monthlyReportTypeId = 4;

  // ── Scoring ────────────────────────────────────────────────────
  /// Daily completion % needed to earn a star
  static const double starThreshold = 0.70;

  /// Points deducted per negative behaviour (from weekly total)
  static const int negativeDeductionPoints = 5;

  /// Monthly score % thresholds for each level
  static const double level2Threshold = 0.50;
  static const double level3Threshold = 0.65;
  static const double level4Threshold = 0.80;
  static const double level5Threshold = 0.95;

  /// Max % drop before level is held (not promoted)
  static const double levelHoldDropThreshold = 0.20;

  // ── Level Names ────────────────────────────────────────────────
  static const List<String> levelNames = [
    'Seedling',       // 1
    'Star Learner',   // 2
    'Rising Star',    // 3
    'Gold Achiever',  // 4
    'Habit Champion', // 5
  ];

  static const List<String> levelEmojis = [
    '🌱', '⭐', '🥈', '🥇', '🏆',
  ];

  /// Minimum monthly score needed to REACH each level (index = level - 1).
  /// Index 0 is level 1 (always starts at 0), subsequent entries are the
  /// thresholds for levels 2–5.
  static const List<double> levelThresholds = [
    0.0,   // Level 1 — Seedling (baseline)
    level2Threshold, // 0.50
    level3Threshold, // 0.65
    level4Threshold, // 0.80
    level5Threshold, // 0.95
  ];

  // ── Default Habits ────────────────────────────────────────────
  static const List<Map<String, dynamic>> defaultHabits = [
    {
      'name': 'Brush Teeth',
      'description': 'Morning & night — 2 minutes each',
      'emoji': '🦷',
      'isPositive': true,
      'sortOrder': 0,
    },
    {
      'name': 'Take a Bath',
      'description': 'Stay clean and fresh every day',
      'emoji': '🛁',
      'isPositive': true,
      'sortOrder': 1,
    },
    {
      'name': 'Read a Book',
      'description': 'Read for at least 15 minutes',
      'emoji': '📚',
      'isPositive': true,
      'sortOrder': 2,
    },
    {
      'name': 'Say Prayers',
      'description': 'Morning or bedtime prayers',
      'emoji': '🙏',
      'isPositive': true,
      'sortOrder': 3,
    },
    {
      'name': 'Eat Meals on Time',
      'description': 'Breakfast, lunch & dinner',
      'emoji': '🍽️',
      'isPositive': true,
      'sortOrder': 4,
    },
    {
      'name': 'Eat Vegetables',
      'description': 'At least one serving today',
      'emoji': '🥦',
      'isPositive': true,
      'sortOrder': 5,
    },
    {
      'name': 'Drink Water',
      'description': 'Drink at least 6 glasses of water',
      'emoji': '💧',
      'isPositive': true,
      'sortOrder': 6,
    },
    {
      'name': 'Exercise & Play',
      'description': 'Outdoor play or exercise',
      'emoji': '🏃',
      'isPositive': true,
      'sortOrder': 7,
    },
    {
      'name': 'Make Bed',
      'description': 'Tidy up the bed in the morning',
      'emoji': '🛏️',
      'isPositive': true,
      'sortOrder': 8,
    },
    {
      'name': 'Tidy Up Room',
      'description': 'Put toys and things back in place',
      'emoji': '🧹',
      'isPositive': true,
      'sortOrder': 9,
    },
    {
      'name': 'Help at Home',
      'description': 'Help parents or siblings',
      'emoji': '🤝',
      'isPositive': true,
      'sortOrder': 10,
    },
    {
      'name': 'Sleep on Time',
      'description': 'Go to bed by bedtime',
      'emoji': '😴',
      'isPositive': true,
      'sortOrder': 11,
    },
    {
      'name': 'Complete Homework',
      'description': 'Finish school work without reminders',
      'emoji': '📝',
      'isPositive': true,
      'sortOrder': 12,
    },
    {
      'name': 'Say Please & Thank You',
      'description': 'Use good manners every day',
      'emoji': '🙌',
      'isPositive': true,
      'sortOrder': 13,
    },
    {
      'name': 'Creative Activity',
      'description': 'Drawing, crafts, or music',
      'emoji': '🎨',
      'isPositive': true,
      'sortOrder': 14,
    },
    // ── Negative Behaviours ───────────────────────────────────
    {
      'name': 'Threw a Tantrum',
      'description': 'Lost temper or cried unreasonably',
      'emoji': '😠',
      'isPositive': false,
      'sortOrder': 0,
    },
    {
      'name': 'Used Bad Words',
      'description': 'Said unkind or rude words',
      'emoji': '🤬',
      'isPositive': false,
      'sortOrder': 1,
    },
    {
      'name': 'Disobeyed Parents',
      'description': 'Refused to listen or follow instructions',
      'emoji': '🚫',
      'isPositive': false,
      'sortOrder': 2,
    },
    {
      'name': 'Fought with Sibling',
      'description': 'Got into an argument or fight',
      'emoji': '😤',
      'isPositive': false,
      'sortOrder': 3,
    },
    {
      'name': 'Excess Screen Time',
      'description': 'Too much phone/tablet/TV time',
      'emoji': '📱',
      'isPositive': false,
      'sortOrder': 4,
    },
  ];

  // ── UI Constants ──────────────────────────────────────────────
  static const double defaultPadding = 20.0;
  static const double smallPadding = 12.0;
  static const double largePadding = 32.0;
  static const double cardRadius = 20.0;
  static const double buttonRadius = 16.0;
  static const double chipRadius = 50.0;
  static const double avatarSizeLg = 80.0;
  static const double avatarSizeMd = 56.0;
  static const double avatarSizeSm = 40.0;
}
