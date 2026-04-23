import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/group_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/leaderboard_card.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync  = ref.watch(userGroupProvider);
    final boardAsync  = ref.watch(leaderboardProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF7C3AED),
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 4),
                    Text('This Week\'s Leaderboard',
                        style: AppTextStyles.h2.copyWith(color: Colors.white)),
                    groupAsync.when(
                      data: (g) => Text(
                        g?.name ?? '',
                        style: AppTextStyles.body.copyWith(color: Colors.white70),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Leaderboard list ─────────────────────────────────────
          boardAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (entries) {
              if (entries.isEmpty) {
                return const SliverFillRemaining(
                  child: _EmptyLeaderboard(),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry  = entries[index];
                      final isMe   = entry.ownerId == currentUser?.uid;
                      final rank   = index + 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LeaderboardCard(
                          rank: rank,
                          entry: entry,
                          isCurrentUser: isMe,
                        ),
                      );
                    },
                    childCount: entries.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌟', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text('No scores yet this week!',
              style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'Tap "Sync My Kids\' Scores" on the Groups screen,\n'
            'then ask your friends to do the same.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
