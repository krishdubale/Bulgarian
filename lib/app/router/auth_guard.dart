import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/auth_repository.dart';
import 'app_routes.dart';

class AuthGuardInput {
  final bool isAuthenticated;
  final String location;

  const AuthGuardInput({
    required this.isAuthenticated,
    required this.location,
  });
}

abstract class AppAuthGuard {
  String? redirect(AuthGuardInput input);
}

class DefaultAuthGuard implements AppAuthGuard {
  const DefaultAuthGuard();

  @override
  String? redirect(AuthGuardInput input) {
    final isAuthRoute = input.location == AppRouteKey.login.path ||
        input.location == AppRouteKey.register.path;
    final isBootRoute = input.location == AppRouteKey.boot.path;

    if (isBootRoute) {
      return input.isAuthenticated
          ? AppRouteKey.home.path
          : AppRouteKey.login.path;
    }

    if (!input.isAuthenticated && !isAuthRoute && !isBootRoute) {
      return AppRouteKey.login.path;
    }

    if (input.isAuthenticated && isAuthRoute) {
      return AppRouteKey.home.path;
    }

    return null;
  }
}

final appAuthGuardProvider = Provider<AppAuthGuard>((ref) {
  return const DefaultAuthGuard();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.status == AuthStatus.authenticated;
});
