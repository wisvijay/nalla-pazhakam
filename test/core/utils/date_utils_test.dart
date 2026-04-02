import 'package:flutter_test/flutter_test.dart';
import 'package:nalla_pazhakam/core/utils/date_utils.dart';

void main() {
  group('NallaDateUtils', () {
    // ── formatAge ──────────────────────────────────────────────
    group('formatAge', () {
      test('returns years only when no leftover months', () {
        final dob = DateTime(
          DateTime.now().year - 7,
          DateTime.now().month,
          DateTime.now().day,
        );
        expect(NallaDateUtils.formatAge(dob), '7 years old');
      });

      test('returns years and months when applicable', () {
        final now = DateTime.now();
        // Born exactly 6 years and 3 months ago
        var month = now.month - 3;
        var year = now.year - 6;
        if (month <= 0) {
          month += 12;
          year--;
        }
        final dob = DateTime(year, month, now.day);
        expect(NallaDateUtils.formatAge(dob), '6 years, 3 months old');
      });

      test('returns months only for babies under 1 year', () {
        final now = DateTime.now();
        var month = now.month - 4;
        var year = now.year;
        if (month <= 0) {
          month += 12;
          year--;
        }
        final dob = DateTime(year, month, now.day);
        expect(NallaDateUtils.formatAge(dob), '4 months old');
      });
    });

    // ── weekStart ──────────────────────────────────────────────
    group('weekStart', () {
      test('returns Monday for a Wednesday', () {
        final wednesday = DateTime(2026, 4, 1); // Wed
        final monday = NallaDateUtils.weekStart(wednesday);
        expect(monday.weekday, DateTime.monday);
        expect(monday, DateTime(2026, 3, 30));
      });

      test('returns the same day when it is Monday', () {
        final monday = DateTime(2026, 3, 30);
        expect(NallaDateUtils.weekStart(monday), monday);
      });

      test('returns correct Monday for Sunday', () {
        final sunday = DateTime(2026, 4, 5);
        final monday = NallaDateUtils.weekStart(sunday);
        expect(monday, DateTime(2026, 3, 30));
      });
    });

    // ── weekEnd ────────────────────────────────────────────────
    group('weekEnd', () {
      test('returns Sunday for a Wednesday', () {
        final wednesday = DateTime(2026, 4, 1);
        final sunday = NallaDateUtils.weekEnd(wednesday);
        expect(sunday.weekday, DateTime.sunday);
        expect(sunday, DateTime(2026, 4, 5));
      });
    });

    // ── daysInWeek ─────────────────────────────────────────────
    group('daysInWeek', () {
      test('returns exactly 7 days', () {
        final days = NallaDateUtils.daysInWeek(DateTime(2026, 4, 1));
        expect(days.length, 7);
      });

      test('first day is Monday, last is Sunday', () {
        final days = NallaDateUtils.daysInWeek(DateTime(2026, 4, 1));
        expect(days.first.weekday, DateTime.monday);
        expect(days.last.weekday, DateTime.sunday);
      });
    });

    // ── isSameDay ──────────────────────────────────────────────
    group('isSameDay', () {
      test('same date with different times returns true', () {
        final a = DateTime(2026, 4, 1, 9, 0);
        final b = DateTime(2026, 4, 1, 23, 59);
        expect(NallaDateUtils.isSameDay(a, b), isTrue);
      });

      test('different dates returns false', () {
        final a = DateTime(2026, 4, 1);
        final b = DateTime(2026, 4, 2);
        expect(NallaDateUtils.isSameDay(a, b), isFalse);
      });
    });

    // ── isSameMonth ────────────────────────────────────────────
    group('isSameMonth', () {
      test('same year/month returns true', () {
        expect(
          NallaDateUtils.isSameMonth(
              DateTime(2026, 4, 1), DateTime(2026, 4, 30)),
          isTrue,
        );
      });

      test('different months returns false', () {
        expect(
          NallaDateUtils.isSameMonth(
              DateTime(2026, 4, 30), DateTime(2026, 5, 1)),
          isFalse,
        );
      });
    });

    // ── dayKey ─────────────────────────────────────────────────
    group('dayKey', () {
      test('formats as YYYY-MM-DD with zero-padding', () {
        expect(
            NallaDateUtils.dayKey(DateTime(2026, 4, 1)), '2026-04-01');
      });

      test('pads single-digit month and day', () {
        expect(
            NallaDateUtils.dayKey(DateTime(2026, 1, 9)), '2026-01-09');
      });
    });

    // ── monthKey ───────────────────────────────────────────────
    group('monthKey', () {
      test('formats as YYYY-MM', () {
        expect(NallaDateUtils.monthKey(DateTime(2026, 4, 15)), '2026-04');
      });
    });

    // ── daysInMonth ────────────────────────────────────────────
    group('daysInMonth', () {
      test('April has 30 days', () {
        final days = NallaDateUtils.daysInMonth(DateTime(2026, 4));
        expect(days.length, 30);
      });

      test('February 2024 (leap year) has 29 days', () {
        final days = NallaDateUtils.daysInMonth(DateTime(2024, 2));
        expect(days.length, 29);
      });

      test('February 2025 (non-leap) has 28 days', () {
        final days = NallaDateUtils.daysInMonth(DateTime(2025, 2));
        expect(days.length, 28);
      });
    });

    // ── formatDay ──────────────────────────────────────────────
    group('formatDay', () {
      test('formats a known date correctly', () {
        // April 1, 2026 is a Wednesday
        final result = NallaDateUtils.formatDay(DateTime(2026, 4, 1));
        expect(result, 'Wednesday, April 1');
      });
    });
  });
}
