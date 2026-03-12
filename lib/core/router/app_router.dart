import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/alphabet/screens/alphabet_screen.dart';
import '../../features/vocabulary/screens/vocabulary_screen.dart';
import '../../features/vocabulary/screens/flashcard_screen.dart';
import '../../features/grammar/screens/grammar_screen.dart';
import '../../features/pronunciation/screens/pronunciation_screen.dart';
import '../../features/listening/screens/listening_screen.dart';
import '../../features/speaking/screens/speaking_screen.dart';
import '../../features/reading/screens/reading_screen.dart';
import '../../features/writing/screens/writing_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vocabulary',
                builder: (context, state) => const VocabularyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/alphabet',
        builder: (context, state) => const AlphabetScreen(),
      ),
      GoRoute(
        path: '/grammar',
        builder: (context, state) => const GrammarScreen(),
      ),
      GoRoute(
        path: '/flashcard',
        builder: (context, state) {
          final category =
              state.uri.queryParameters['category'] ?? 'Greetings';
          return FlashcardScreen(category: category);
        },
      ),
      GoRoute(
        path: '/pronunciation',
        builder: (context, state) => const PronunciationScreen(),
      ),
      GoRoute(
        path: '/listening',
        builder: (context, state) => const ListeningScreen(),
      ),
      GoRoute(
        path: '/speaking',
        builder: (context, state) => const SpeakingScreen(),
      ),
      GoRoute(
        path: '/reading',
        builder: (context, state) => const ReadingScreen(),
      ),
      GoRoute(
        path: '/writing',
        builder: (context, state) => const WritingScreen(),
      ),
    ],
  );
});

class _MainShell extends StatelessWidget {
  const _MainShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: 'Vocabulary',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
