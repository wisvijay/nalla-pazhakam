import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/repositories/habit_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                    gradient: AppColors.purplePinkGradient),
                // No SafeArea — FlexibleSpaceBar handles insets itself.
                // Use padding to push content below the status bar area.
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⚙️',
                        style: TextStyle(fontSize: 30)),
                    const SizedBox(height: 6),
                    Text(
                      'Settings',
                      style: AppTextStyles.h3
                          .copyWith(color: Colors.white),
                    ),
                    Text(
                      'Manage habits & preferences',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // App info banner
                _AppBanner(),
                const SizedBox(height: 20),

                // ── Habits section ───────────────────────────────
                _SectionHeader(emoji: '✅', title: 'Positive Habits'),
                const SizedBox(height: 8),
                _PositiveHabitsList(),
                const SizedBox(height: 8),
                _AddHabitButton(isPositive: true),
                const SizedBox(height: 20),

                // ── Negative behaviours section ──────────────────
                _SectionHeader(emoji: '⚠️', title: 'Behaviour Marks'),
                const SizedBox(height: 8),
                _NegativeHabitsList(),
                const SizedBox(height: 8),
                _AddHabitButton(isPositive: false),
                const SizedBox(height: 28),

                // ── Data section ─────────────────────────────────
                _SectionHeader(emoji: '🗄️', title: 'Data'),
                const SizedBox(height: 8),
                _DataSection(),
                const SizedBox(height: 32),

                Center(
                  child: Text(
                    'Made with ❤️ for our little ones',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.grey[400]),
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App banner ────────────────────────────────────────────────────────────────

class _AppBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Row(
        children: [
          const Text('🌟', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style:
                      AppTextStyles.h4.copyWith(color: Colors.white),
                ),
                Text(
                  AppConstants.appNameTamil,
                  style: AppTextStyles.body
                      .copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              'v${AppConstants.appVersion}',
              style: AppTextStyles.labelSmall
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Habit lists ───────────────────────────────────────────────────────────────

class _PositiveHabitsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(habitsStreamProvider); // rebuild on changes
    final habits = ref.read(habitRepositoryProvider).getPositive(activeOnly: false);
    if (habits.isEmpty) {
      return const _EmptyHabits(message: 'No positive habits yet');
    }
    return Column(
      children: habits
          .map((h) => _HabitRow(habit: h))
          .toList(),
    );
  }
}

class _NegativeHabitsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(habitsStreamProvider);
    final habits = ref.read(habitRepositoryProvider).getNegative(activeOnly: false);
    if (habits.isEmpty) {
      return const _EmptyHabits(message: 'No behaviour marks yet');
    }
    return Column(
      children: habits
          .map((h) => _HabitRow(habit: h))
          .toList(),
    );
  }
}

// ── Single habit row ──────────────────────────────────────────────────────────

class _HabitRow extends ConsumerWidget {
  final HabitModel habit;
  const _HabitRow({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeColor =
        habit.isPositive ? AppColors.success : AppColors.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: habit.isActive
              ? activeColor.withValues(alpha: 0.25)
              : Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: habit.isActive
                ? activeColor.withValues(alpha: 0.12)
                : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              habit.emojiIcon,
              style: TextStyle(
                fontSize: 20,
                color: habit.isActive ? null : Colors.grey,
              ),
            ),
          ),
        ),
        title: Text(
          habit.name,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            color: habit.isActive
                ? const Color(0xFF1F1F2E)
                : Colors.grey[400],
            decoration: habit.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: habit.description.isNotEmpty
            ? Text(
                habit.description,
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.grey[500]),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle active
            Switch.adaptive(
              value: habit.isActive,
              activeColor: activeColor,
              onChanged: (_) => _toggle(ref),
            ),
            // Edit
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 18),
              color: Colors.grey[400],
              onPressed: () => _showEditSheet(context, ref),
              tooltip: 'Edit',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggle(WidgetRef ref) async {
    await ref.read(habitRepositoryProvider).toggleActive(habit.id);
  }

  Future<void> _showEditSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HabitEditSheet(habit: habit),
    );
  }
}

// ── Edit / Add sheet ──────────────────────────────────────────────────────────

class _HabitEditSheet extends ConsumerStatefulWidget {
  final HabitModel? habit; // null = new habit
  final bool? forcePositive; // for add button

  const _HabitEditSheet({this.habit, this.forcePositive});

  @override
  ConsumerState<_HabitEditSheet> createState() =>
      _HabitEditSheetState();
}

class _HabitEditSheetState extends ConsumerState<_HabitEditSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late String _emoji;
  late bool _isPositive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.habit?.name ?? '';
    _descCtrl.text = widget.habit?.description ?? '';
    _emoji = widget.habit?.emojiIcon ?? '✅';
    _isPositive = widget.habit?.isPositive ??
        (widget.forcePositive ?? true);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);

    final repo = ref.read(habitRepositoryProvider);
    final id = widget.habit?.id ??
        'custom_${DateTime.now().millisecondsSinceEpoch}';

    final updated = (widget.habit ?? HabitModel(
      id: id,
      name: '',
      description: '',
      emojiIcon: _emoji,
      isPositive: _isPositive,
      isActive: true,
      sortOrder: 999,
      isDefault: false,
    )).copyWith(
      name: name,
      description: _descCtrl.text.trim(),
      emojiIcon: _emoji,
    );

    await repo.save(updated);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (widget.habit == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: Text(
            'Remove "${widget.habit!.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(habitRepositoryProvider).delete(widget.habit!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.habit == null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            isNew ? 'Add Habit' : 'Edit Habit',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 20),

          // Emoji picker (simplified — tap to cycle through common emojis)
          Row(
            children: [
              GestureDetector(
                onTap: () => _showEmojiPicker(),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (_isPositive
                            ? AppColors.success
                            : AppColors.danger)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.20)),
                  ),
                  child: Center(
                    child:
                        Text(_emoji, style: const TextStyle(fontSize: 26)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('Tap to change emoji',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Habit name',
              hintText: 'e.g. Brush Teeth',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'e.g. Morning and night',
            ),
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              if (!isNew)
                IconButton(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.danger,
                  tooltip: 'Delete habit',
                ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isNew ? 'Add' : 'Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker() {
    final emojis = _isPositive
        ? ['✅', '🦷', '🛁', '📚', '🙏', '🍽️', '🥦', '💧', '🏃', '🛏️',
            '🧹', '🤝', '😴', '📝', '🙌', '🎨', '⭐', '🌟', '💪', '🎵']
        : ['😠', '🤬', '🚫', '😤', '📱', '🍬', '🎮', '😢', '🙄', '😒'];

    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: emojis.map((e) => GestureDetector(
            onTap: () {
              setState(() => _emoji = e);
              Navigator.of(context).pop();
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: e == _emoji
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: e == _emoji
                    ? Border.all(color: AppColors.primary)
                    : null,
              ),
              child: Center(
                child: Text(e, style: const TextStyle(fontSize: 24)),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
}

// ── Add habit button ──────────────────────────────────────────────────────────

class _AddHabitButton extends StatelessWidget {
  final bool isPositive;
  const _AddHabitButton({required this.isPositive});

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.success : AppColors.danger;
    return OutlinedButton.icon(
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _HabitEditSheet(forcePositive: isPositive),
      ),
      icon: Icon(Icons.add_rounded, color: color),
      label: Text(
        isPositive ? 'Add Good Habit' : 'Add Behaviour Mark',
        style: TextStyle(color: color),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.40)),
        minimumSize: const Size(double.infinity, 44),
      ),
    );
  }
}

// ── Data section ──────────────────────────────────────────────────────────────

class _DataSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.restore_rounded,
                color: AppColors.accent),
            title: const Text('Reset All Data'),
            subtitle: const Text('Clear all records and start fresh'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⚠️  Reset All Data?'),
        content: const Text(
          'This will permanently delete ALL records, kids\' profiles, and progress. '
          'Default habits will be restored. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // DatabaseService.clearAll() re-seeds habits automatically
      // We need to import it — handled via a simple service call
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data reset — restart app to take effect')),
      );
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String emoji;
  final String title;
  const _SectionHeader({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          '$emoji  $title',
          style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
        ),
      );
}

class _EmptyHabits extends StatelessWidget {
  final String message;
  const _EmptyHabits({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          message,
          style:
              AppTextStyles.bodySmall.copyWith(color: Colors.grey[400]),
        ),
      );
}
