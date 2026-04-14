import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/basic_learning/screens/basic_flow.dart';
import '../../features/path/screens/path_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/shared.dart';
import 'app_routes.dart';
import 'auth_guard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final authGuard = ref.watch(appAuthGuardProvider);

  return GoRouter(
    initialLocation: AppRouteKey.boot.path,
    redirect: (context, state) {
      return authGuard.redirect(
        AuthGuardInput(
          isAuthenticated: isAuthenticated,
          location: state.matchedLocation,
        ),
      );
    },
    routes: [
      GoRoute(
        path: AppRouteKey.boot.path,
        builder: (context, state) => const MinimalBootScreen(
          title: 'Starting app...',
        ),
      ),
      GoRoute(
        path: AppRouteKey.login.path,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouteKey.register.path,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRouteKey.onboarding.path,
        builder: (context, state) => const MinimalBootScreen(
          title: 'Onboarding',
        ),
      ),
      GoRoute(
        path: AppRouteKey.home.path,
        builder: (context, state) => const BasicHomeScreen(),
      ),
      GoRoute(
        path: AppRouteKey.path.path,
        builder: (context, state) => const PathScreen(),
      ),
      GoRoute(
        path: AppRouteKey.profileSettings.path,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Route not found'),
              const SizedBox(height: 8),
              Text('Attempted route: ${state.matchedLocation}'),
              const SizedBox(height: 4),
              const Text('That page is unavailable right now.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRouteKey.home.path),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
