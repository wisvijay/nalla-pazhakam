import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/kid_profile/screens/kid_profile_screen.dart';
import '../../features/kid_dashboard/screens/kid_dashboard_screen.dart';
import '../../features/daily_tracker/screens/daily_tracker_screen.dart';
import '../../features/weekly_report/screens/weekly_report_screen.dart';
import '../../features/monthly_report/screens/monthly_report_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/groups/screens/groups_screen.dart';
import '../../features/groups/screens/leaderboard_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

abstract class AppRoutes {
  static const String home        = '/';
  static const String addKid      = '/kids/add';
  static const String editKid     = '/kids/:kidId/edit';
  static const String kidDashboard= '/kids/:kidId';
  static const String dailyTracker= '/kids/:kidId/daily';
  static const String weeklyReport= '/kids/:kidId/weekly';
  static const String monthlyReport='/kids/:kidId/monthly';
  static const String settings    = '/settings';
  static const String manageHabits= '/settings/habits';
  static const String groups      = '/groups';
  static const String leaderboard = '/groups/leaderboard';
  static const String auth        = '/auth';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    routes: [
      // ── Shell with bottom nav ──────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.groups,
            name: 'groups',
            builder: (context, state) => const GroupsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // ── Auth (slide up) ────────────────────────────────────────
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        pageBuilder: (context, state) => _slideUpPage(
          state,
          const AuthScreen(),
        ),
      ),

      // ── Leaderboard (slide up) ─────────────────────────────────
      GoRoute(
        path: AppRoutes.leaderboard,
        name: 'leaderboard',
        pageBuilder: (context, state) => _slideUpPage(
          state,
          const LeaderboardScreen(),
        ),
      ),

      // ── Add / Edit kid ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.addKid,
        name: 'addKid',
        pageBuilder: (context, state) => _slideUpPage(
          state,
          const KidProfileScreen(kidId: null),
        ),
      ),
      GoRoute(
        path: AppRoutes.editKid,
        name: 'editKid',
        pageBuilder: (context, state) {
          final kidId = state.pathParameters['kidId'];
          return _slideUpPage(
            state,
            KidProfileScreen(kidId: null, kidStringId: kidId),
          );
        },
      ),

      // ── Kid dashboard ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.kidDashboard,
        name: 'kidDashboard',
        pageBuilder: (context, state) {
          final kidId = state.pathParameters['kidId']!;
          return _slidePage(state, KidDashboardScreen(kidId: kidId));
        },
      ),

      // ── Daily Tracker ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.dailyTracker,
        name: 'dailyTracker',
        pageBuilder: (context, state) {
          final kidId  = state.pathParameters['kidId']!;
          final dateStr= state.uri.queryParameters['date'];
          return _slidePage(
            state,
            DailyTrackerScreen(
              kidId: kidId,
              date: dateStr != null ? DateTime.parse(dateStr) : DateTime.now(),
            ),
          );
        },
      ),

      // ── Weekly Report ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.weeklyReport,
        name: 'weeklyReport',
        pageBuilder: (context, state) {
          final kidId = state.pathParameters['kidId']!;
          return _slidePage(state, WeeklyReportScreen(kidId: kidId));
        },
      ),

      // ── Monthly Report ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.monthlyReport,
        name: 'monthlyReport',
        pageBuilder: (context, state) {
          final kidId = state.pathParameters['kidId']!;
          return _slidePage(state, MonthlyReportScreen(kidId: kidId));
        },
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Page not found',
                style: Theme.of(context).textTheme.headlineSmall),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );

CustomTransitionPage<void> _slideUpPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );
