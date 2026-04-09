import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/group_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/sync_service.dart';
import '../../../data/models/group_model.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../data/repositories/kid_repository.dart';
import '../../../data/repositories/achievement_repository.dart';
import '../../../shared/widgets/gradient_button.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  final _createCtrl = TextEditingController();
  final _joinCtrl   = TextEditingController();
  bool _creating = false;
  bool _joining  = false;

  @override
  void dispose() {
    _createCtrl.dispose();
    _joinCtrl.dispose();
    super.dispose();
  }

  // ── Create group ─────────────────────────────────────────────────────────
  Future<void> _createGroup() async {
    final name = _createCtrl.text.trim();
    if (name.isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _creating = true);
    try {
      await ref.read(groupRepositoryProvider).createGroup(
        name: name,
        userId: user.uid,
        displayName: user.displayName ?? user.email ?? 'Parent',
      );
      ref.invalidate(userGroupProvider);
      _createCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Group created! Share your join code with friends.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError('Failed to create group: $e');
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  // ── Join group by code ───────────────────────────────────────────────────
  Future<void> _joinGroup() async {
    final code = _joinCtrl.text.trim().toUpperCase();
    if (code.length != 6) {
      _showError('Please enter the 6-character join code.');
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _joining = true);
    try {
      final group = await ref.read(groupRepositoryProvider).joinGroup(
        joinCode: code,
        userId: user.uid,
        displayName: user.displayName ?? user.email ?? 'Parent',
      );
      if (group == null) {
        if (mounted) _showError('No group found with that code. Double-check and try again.');
        return;
      }
      ref.invalidate(userGroupProvider);
      _joinCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Joined "${group.name}"!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError('Failed to join group: $e');
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  // ── Leave group ──────────────────────────────────────────────────────────
  Future<void> _confirmLeave(GroupModel group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Group?'),
        content: Text('You will leave "${group.name}". '
            'Your scores will no longer appear on the leaderboard.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await ref.read(groupRepositoryProvider).leaveGroup(group.id, user.uid);
    ref.invalidate(userGroupProvider);
  }

  // ── Sync scores ──────────────────────────────────────────────────────────
  Future<void> _syncScores(GroupModel group) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final kids = ref.read(kidsListProvider);
    if (kids.isEmpty) return;
    final achievementRepo = ref.read(achievementRepositoryProvider);

    try {
      await SyncService.syncAllKids(
        kids: kids,
        userId: user.uid,
        groupId: group.id,
        achievementRepo: achievementRepo,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Scores synced to leaderboard!')),
        );
      }
    } catch (e) {
      if (mounted) _showError('Sync failed: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Join code copied!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready     = ref.watch(firebaseReadyProvider);
    final isSignedIn= ref.watch(isSignedInProvider);
    final user      = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            actions: isSignedIn
                ? [
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      tooltip: 'Sign out',
                      onPressed: () async {
                        await AuthService.signOut();
                        ref.invalidate(userGroupProvider);
                      },
                    ),
                    const SizedBox(width: 4),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Groups 👥',
                        style: AppTextStyles.h2.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      isSignedIn
                          ? 'Hi ${user?.displayName ?? "there"} 👋'
                          : 'Compete with friends & family',
                      style: AppTextStyles.body.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            sliver: SliverToBoxAdapter(
              child: !ready
                  ? _FirebaseSetupCard()
                  : !isSignedIn
                      ? _SignInCard()
                      : _GroupContent(
                          onSyncScores: _syncScores,
                          onLeave: _confirmLeave,
                          onJoin: _joinGroup,
                          onCreate: _createGroup,
                          joinCtrl: _joinCtrl,
                          createCtrl: _createCtrl,
                          creating: _creating,
                          joining: _joining,
                          onCopyCode: _copyCode,
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Firebase not configured card ─────────────────────────────────────────────
class _FirebaseSetupCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Text('🔧', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Firebase Setup Required', style: AppTextStyles.h3,
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'To enable group leaderboards, set up Firebase:\n\n'
            '1. Create a project at firebase.google.com\n'
            '2. Enable Email/Password auth and Firestore\n'
            '3. Run: dart pub global activate flutterfire_cli\n'
            '4. Run: flutterfire configure\n'
            '5. Set kFirebaseConfigured = true in firebase_options.dart',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ── Sign-in prompt card ───────────────────────────────────────────────────────
class _SignInCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Text('🔐', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('Sign In to Join a Group', style: AppTextStyles.h3,
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            'Create an account or sign in to connect with\nyour kids\' friends and compete on the leaderboard.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Sign In / Create Account',
            icon: Icons.login_rounded,
            onPressed: () => context.push(AppRoutes.auth),
          ),
        ],
      ),
    );
  }
}

// ── Group content (create/join OR group dashboard) ────────────────────────────
class _GroupContent extends ConsumerWidget {
  final Future<void> Function(GroupModel) onSyncScores;
  final Future<void> Function(GroupModel) onLeave;
  final VoidCallback onJoin;
  final VoidCallback onCreate;
  final TextEditingController joinCtrl;
  final TextEditingController createCtrl;
  final bool creating;
  final bool joining;
  final void Function(String) onCopyCode;

  const _GroupContent({
    required this.onSyncScores,
    required this.onLeave,
    required this.onJoin,
    required this.onCreate,
    required this.joinCtrl,
    required this.createCtrl,
    required this.creating,
    required this.joining,
    required this.onCopyCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(userGroupProvider);

    return groupAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 48),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (group) => group == null
          ? _NoGroupView(
              joinCtrl: joinCtrl,
              createCtrl: createCtrl,
              onCreate: onCreate,
              onJoin: onJoin,
              creating: creating,
              joining: joining,
            )
          : _HasGroupView(
              group: group,
              onSyncScores: onSyncScores,
              onLeave: onLeave,
              onCopyCode: onCopyCode,
            ),
    );
  }
}

// ── No group yet — create or join ────────────────────────────────────────────
class _NoGroupView extends StatelessWidget {
  final TextEditingController joinCtrl;
  final TextEditingController createCtrl;
  final VoidCallback onCreate;
  final VoidCallback onJoin;
  final bool creating;
  final bool joining;

  const _NoGroupView({
    required this.joinCtrl,
    required this.createCtrl,
    required this.onCreate,
    required this.onJoin,
    required this.creating,
    required this.joining,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Join card
        _card(
          emoji: '🔗',
          title: 'Join a Group',
          subtitle: 'Enter the 6-character code shared by a friend.',
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: joinCtrl,
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  style: AppTextStyles.h3.copyWith(letterSpacing: 4),
                  decoration: const InputDecoration(
                    hintText: 'ABC123',
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: joining ? null : onJoin,
                child: joining
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Join'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Create card
        _card(
          emoji: '✨',
          title: 'Create a Group',
          subtitle: 'Start a new group and invite your kids\' friends.',
          child: Column(
            children: [
              TextField(
                controller: createCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Class 4B Habit Club',
                  prefixIcon: Icon(Icons.groups_rounded),
                ),
              ),
              const SizedBox(height: 12),
              GradientButton(
                label: 'Create Group',
                icon: Icons.add_rounded,
                onPressed: onCreate,
                loading: creating,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({
    required String emoji,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTextStyles.h4),
              Text(subtitle, style: AppTextStyles.bodySmall),
            ]),
          ]),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// ── Already in a group ───────────────────────────────────────────────────────
class _HasGroupView extends StatelessWidget {
  final GroupModel group;
  final Future<void> Function(GroupModel) onSyncScores;
  final Future<void> Function(GroupModel) onLeave;
  final void Function(String) onCopyCode;

  const _HasGroupView({
    required this.group,
    required this.onSyncScores,
    required this.onLeave,
    required this.onCopyCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Group info card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('👥', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(group.name,
                      style: AppTextStyles.h3.copyWith(color: Colors.white)),
                ),
              ]),
              const SizedBox(height: 16),
              Text('Join Code', style: AppTextStyles.labelSmall
                  .copyWith(color: Colors.white60)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => onCopyCode(group.joinCode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        group.joinCode,
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text('Tap to copy · Share with friends',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Leaderboard button
        GradientButton(
          label: 'View Leaderboard 🏆',
          icon: Icons.leaderboard_rounded,
          onPressed: () => context.push(AppRoutes.leaderboard),
        ),

        const SizedBox(height: 12),

        // Sync button
        OutlinedButton.icon(
          onPressed: () => onSyncScores(group),
          icon: const Icon(Icons.sync_rounded),
          label: const Text('Sync My Kids\' Scores'),
        ),

        const SizedBox(height: 24),

        // Leave group
        TextButton(
          onPressed: () => onLeave(group),
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: const Text('Leave Group'),
        ),
      ],
    );
  }
}
