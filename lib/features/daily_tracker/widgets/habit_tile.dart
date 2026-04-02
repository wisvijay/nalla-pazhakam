import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/habit_model.dart';

/// A single habit row in the daily tracker.
/// Tapping it toggles completion with a satisfying bounce + colour change.
class HabitTile extends StatefulWidget {
  final HabitModel habit;
  final bool isCompleted;
  final ValueChanged<bool> onToggle;

  const HabitTile({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _checkAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.92)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 0.92, end: 1.06)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.06, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 30),
    ]).animate(_controller);

    _checkAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _controller.forward(from: 0);
    widget.onToggle(!widget.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.habit.isPositive;
    final completed = widget.isCompleted;

    // Color scheme differs for positive vs negative habits
    final activeColor = isPositive ? AppColors.success : AppColors.danger;
    final activeBg = isPositive
        ? AppColors.success.withValues(alpha: 0.08)
        : AppColors.danger.withValues(alpha: 0.08);
    final activeBorder = isPositive
        ? AppColors.success.withValues(alpha: 0.40)
        : AppColors.danger.withValues(alpha: 0.40);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: completed ? activeBg : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: completed
                  ? activeBorder
                  : Colors.grey.withValues(alpha: 0.18),
              width: completed ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: completed
                    ? activeColor.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: completed ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Emoji icon ───────────────────────────────────────────
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: completed
                      ? activeColor.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.habit.emojiIcon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Name + description ───────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: completed
                            ? activeColor
                            : const Color(0xFF1F1F2E),
                        decoration: (!isPositive && completed)
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.danger,
                      ),
                    ),
                    if (widget.habit.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.habit.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // ── Checkbox ──────────────────────────────────────────────
              AnimatedBuilder(
                animation: _checkAnim,
                builder: (context, _) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: completed ? activeColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: completed
                            ? activeColor
                            : Colors.grey.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                    child: completed
                        ? Icon(
                            isPositive
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
