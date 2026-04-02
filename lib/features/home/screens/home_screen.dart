import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/repositories/kid_repository.dart';
import '../widgets/kid_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kidsAsync = ref.watch(kidsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ────────────────────────────────────
          SliverAppBar(
            expandedHeight: 170,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                tooltip: 'Add child',
                onPressed: () => context.push(AppRoutes.addKid),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.purplePinkGradient,
                ),
                padding: const EdgeInsets.fromLTRB(24, 72, 24, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: AppTextStyles.h2
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NallaDateUtils.formatDay(DateTime.now()),
                      style: AppTextStyles.body
                          .copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Kids list ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            sliver: kidsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $e')),
              ),
              data: (kids) {
                if (kids.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _EmptyState(
                      onAdd: () => context.push(AppRoutes.addKid),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${kids.length} ${kids.length == 1 ? 'Child' : 'Children'}',
                                style: AppTextStyles.h3,
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    context.push(AppRoutes.addKid),
                                icon: const Icon(Icons.add_rounded,
                                    size: 18),
                                label: const Text('Add'),
                              ),
                            ],
                          ),
                        );
                      }
                      return KidCard(kid: kids[index - 1]);
                    },
                    childCount: kids.length + 1,
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: kidsAsync.maybeWhen(
        data: (kids) => kids.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: () => context.push(AppRoutes.addKid),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Add Child'),
              ),
        orElse: () => null,
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning! 🌞';
    if (h < 17) return 'Good Afternoon! ☀️';
    return 'Good Evening! 🌙';
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text('No children added yet',
              style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            'Add your first child to start tracking\ngood habits every day!',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Add First Child'),
          ),
        ],
      ),
    );
  }
}
