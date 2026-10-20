import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/enums.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../features/dashboard/presentation/student_dashboard.dart';
import '../../features/dashboard/presentation/warden_dashboard.dart';
import '../../features/dashboard/presentation/guard_dashboard.dart';
import '../../features/admin/presentation/upload_csv_screen.dart';
import '../../features/dashboard/presentation/guard_dashboard.dart';
import '../../features/dashboard/presentation/mess_incharge_dashboard.dart';
import '../../features/auth/presentation/login_screen.dart';

// We wrap GoRouter in a Riverpod Provider so it can access our auth state
final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch the current user. If it changes, the router rebuilds.
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/', // The app starts here

    // Redirect logic: Intercepts navigation based on rules
    redirect: (context, state) {
      final isAtRoot = state.uri.toString() == '/';

      // If no user is logged in (e.g., app just launched), send to login screen.
      // (We will build the login screen later, but the logic stays here)
      if (user == null) {
        return '/login';
      }

      // If the user IS logged in and is at the root route ('/'),
      // direct them to their specific role dashboard.
      if (isAtRoot) {
        switch (user.role) {
          case UserRole.student:
            return '/student';
          case UserRole.warden:
            return '/warden';
          case UserRole.guard:
            return '/guard';
          case UserRole.messIncharge:
            return '/mess'; // Placeholder for later
          case UserRole.superAdmin:
            return '/admin'; // Placeholder for later
        }
      }

      // Return null means "no redirect needed, proceed normally"
      return null;
    },

    // Define the actual routes
    routes: [
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(
        path: '/warden',
        builder: (context, state) => const WardenDashboard(), // We will build this next!
      ),
      GoRoute(
        path: '/guard',
        builder: (context, state) => const GuardDashboard(),
      ),

      // Temporary placeholders for incomplete roles to prevent crashes
      GoRoute(
        path: '/mess',
        builder: (context, state) => const MessInchargeDashboard(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const UploadCsvScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
});