enum AppRouteKey {
  boot,
  login,
  register,
  onboarding,
  home,
  path,
  profileSettings,
}

extension AppRouteKeyX on AppRouteKey {
  String get path {
    switch (this) {
      case AppRouteKey.boot:
        return '/boot';
      case AppRouteKey.login:
        return '/login';
      case AppRouteKey.register:
        return '/register';
      case AppRouteKey.onboarding:
        return '/onboarding';
      case AppRouteKey.home:
        return '/';
      case AppRouteKey.path:
        return '/path';
      case AppRouteKey.profileSettings:
        return '/settings';
    }
  }
}
