import 'package:intl/intl.dart';

/// Date and time utilities for Nalla Pazhakam
abstract class NallaDateUtils {
  // ── Formatters ────────────────────────────────────────────────
  static String formatDay(DateTime date) =>
      DateFormat('EEEE, MMMM d').format(date); // "Tuesday, April 1"

  static String formatShortDate(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date); // "Apr 1, 2026"

  static String formatMonthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date); // "April 2026"

  static String formatWeekRange(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (weekStart.month == weekEnd.month) {
      return '${DateFormat('MMM d').format(weekStart)} – ${DateFormat('d, yyyy').format(weekEnd)}';
    }
    return '${DateFormat('MMM d').format(weekStart)} – ${DateFormat('MMM d, yyyy').format(weekEnd)}';
  }

  static String formatAge(DateTime dob) {
    final now = DateTime.now();
    int years = now.year - dob.year;
    int months = now.month - dob.month;
    if (now.day < dob.day) months--;
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years == 0) return '$months months old';
    if (months == 0) return '$years years old';
    return '$years years, $months months old';
  }

  // ── Week helpers ──────────────────────────────────────────────
  /// Returns Monday of the week containing [date]
  static DateTime weekStart(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// Returns Sunday of the week containing [date]
  static DateTime weekEnd(DateTime date) =>
      weekStart(date).add(const Duration(days: 6));

  /// Returns list of 7 days in the week containing [date]
  static List<DateTime> daysInWeek(DateTime date) {
    final start = weekStart(date);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  static int weekNumber(DateTime date) {
    final dayOfYear =
        date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  // ── Month helpers ─────────────────────────────────────────────
  static DateTime monthStart(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime monthEnd(DateTime date) =>
      DateTime(date.year, date.month + 1, 0);

  static List<DateTime> daysInMonth(DateTime date) {
    final start = monthStart(date);
    final end = monthEnd(date);
    return List.generate(
      end.day,
      (i) => start.add(Duration(days: i)),
    );
  }

  // ── Comparison helpers ────────────────────────────────────────
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameWeek(DateTime a, DateTime b) =>
      isSameDay(weekStart(a), weekStart(b));

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static bool isPast(DateTime date) {
    final today = DateTime.now();
    return date.isBefore(DateTime(today.year, today.month, today.day));
  }

  // ── Date-only key (for Hive keys) ─────────────────────────────
  static String dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  static String weekKey(DateTime date) {
    final ws = weekStart(date);
    return 'W${weekNumber(ws)}-${ws.year}';
  }
}
