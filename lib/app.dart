import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/language_manager.dart';
import 'features/settings/screens/settings_screen.dart';

class LinguaFlowApp extends ConsumerWidget {
  const LinguaFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    final router = ref.watch(routerProvider);
    final language = ref.watch(selectedLanguageProvider);

    return MaterialApp.router(
      title: 'LinguaFlow – ${language.name}',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
