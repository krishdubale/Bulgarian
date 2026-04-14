enum AppRouteKey {
  boot,
  login,
  register,
  onboarding,
  home,
  path,
  profileSettings,
  unit,
  lesson,
  practice,
  review,
  checkpoint,
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
      case AppRouteKey.unit:
        return '/unit/:unitId';
      case AppRouteKey.lesson:
        return '/lesson/:lessonId';
      case AppRouteKey.practice:
        return '/practice';
      case AppRouteKey.review:
        return '/review';
      case AppRouteKey.checkpoint:
        return '/checkpoint/:unitId';
    }
  }
}
