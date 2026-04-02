import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';

/// Top date navigator — shows formatted date with prev/next arrows.
/// The "next" arrow is disabled when already on today.
class DayNavigator extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;

  const DayNavigator({
    super.key,
    required this.date,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = NallaDateUtils.isToday(date);
    final isTomorrow = date.isAfter(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Previous day ─────────────────────────────────────────────
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onPressed: () => onDateChanged(
              date.subtract(const Duration(days: 1)),
            ),
          ),

          // ── Date label ───────────────────────────────────────────────
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isToday)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'TODAY',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(date),
                  style: AppTextStyles.h4.copyWith(
                    color: const Color(0xFF1F1F2E),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month_rounded,
                        size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Text(
                      'tap to pick',
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Next day ─────────────────────────────────────────────────
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onPressed: isTomorrow
                ? null // Can't go beyond today
                : () => onDateChanged(
                      date.add(const Duration(days: 1)),
                    ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      helpText: 'Pick a day to review',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 28,
            color: onPressed == null
                ? Colors.grey.withValues(alpha: 0.30)
                : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
