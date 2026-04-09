import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/group_model.dart';

class LeaderboardCard extends StatelessWidget {
  final int rank;
  final WeeklyScoreEntry entry;
  final bool isCurrentUser;

  const LeaderboardCard({
    super.key,
    required this.rank,
    required this.entry,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;
    final rankEmoji  = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withOpacity(0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(
          color: isCurrentUser ? AppColors.primary : AppColors.borderLight,
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: _medalColor(rank).withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // ── Rank ────────────────────────────────────────────────
          SizedBox(
            width: 40,
            child: rankEmoji != null
                ? Text(rankEmoji, style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center)
                : Text(
                    '#$rank',
                    style: AppTextStyles.h4.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 12),

          // ── Avatar ──────────────────────────────────────────────
          CircleAvatar(
            radius: 22,
            backgroundColor: _avatarColor(entry.kidName),
            child: Text(
              entry.kidName.isNotEmpty
                  ? entry.kidName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Name + level ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.kidName,
                        style: AppTextStyles.bodyBold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('You',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: Colors.white)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Level ${entry.currentLevel}  •  ${(entry.scorePercent * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          // ── Stars ─────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StarRow(stars: entry.stars),
              const SizedBox(height: 2),
              Text('/ 7 stars',
                  style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Color _medalColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return Colors.transparent;
    }
  }

  Color _avatarColor(String name) {
    final colors = [
      AppColors.primary,
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFFDC2626),
      const Color(0xFF7C3AED),
      const Color(0xFF2563EB),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}

// ── Animated star row ─────────────────────────────────────────────────────────
class _StarRow extends StatelessWidget {
  final int stars;
  const _StarRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (i) {
        final filled = i < stars;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 16,
          color: filled ? const Color(0xFFFBBF24) : AppColors.borderLight,
        );
      }),
    );
  }
}
