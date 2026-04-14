import 'package:flutter/widgets.dart';

import '../core/config/config.dart';

class AppBootstrapResult {
  final AppEnvironment environment;
  final DiContainer di;

  const AppBootstrapResult({
    required this.environment,
    required this.di,
  });
}

class AppBootstrap {
  AppBootstrap._();

  static Future<AppBootstrapResult>? _inflight;

  static Future<AppBootstrapResult> initialize() {
    return _inflight ??= _initializeInternal();
  }

  static Future<AppBootstrapResult> _initializeInternal() async {
    WidgetsFlutterBinding.ensureInitialized();
    final environment = AppEnvironment.fromDartDefines();
    await const FirebaseInitializer().initialize(enabled: environment.useFirebase);
    final di = await const DiInitializer().initialize();
    return AppBootstrapResult(environment: environment, di: di);
  }
}

