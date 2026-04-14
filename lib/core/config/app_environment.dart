class AppEnvironment {
  final String flavor;
  final bool useFirebase;

  const AppEnvironment({
    required this.flavor,
    required this.useFirebase,
  });

  static AppEnvironment fromDartDefines() {
    const flavor = String.fromEnvironment(
      'APP_FLAVOR',
      defaultValue: 'prod',
    );
    const firebaseEnabled = bool.fromEnvironment(
      'USE_FIREBASE',
      defaultValue: true,
    );
    return AppEnvironment(
      flavor: flavor,
      useFirebase: firebaseEnabled,
    );
  }
}

