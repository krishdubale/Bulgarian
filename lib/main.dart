import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_bootstrap.dart';
import 'app.dart';
import 'core/providers/app_providers.dart';

void main() async {
  final bootstrap = await AppBootstrap.initialize();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider
            .overrideWithValue(bootstrap.di.sharedPreferences),
        appEnvironmentProvider.overrideWithValue(bootstrap.environment),
      ],
      child: const LinguaFlowApp(),
    ),
  );
}
