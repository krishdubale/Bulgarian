import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/lesson_session_model.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/services/daily_session_service.dart';
import '../../../data/services/language_manager.dart';
import '../../lesson/screens/lesson_session_screen.dart';

final dailyPlanProvider = FutureProvider<DailyPlan>((ref) async {
  final dailyService = ref.watch(dailySessionServiceProvider);
  final progress = ref.watch(userProgressProvider);
  final language = ref.watch(selectedLanguageProvider);
  return dailyService.getDailyPlan(
    languageId: language.id,
    progress: progress,
  );
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final language = ref.watch(selectedLanguageProvider);
    final dailyPlan = ref.watch(dailyPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Session'),
        actions: [
          IconButton(
            tooltip: 'Path',
            onPressed: () => context.push('/path'),
            icon: const Icon(Icons.alt_route),
          ),
          IconButton(
            tooltip: 'Profile & Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${language.flag} ${language.name}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Daily streak: ${progress.streakDays} • XP today: ${progress.todayXp}/${progress.dailyGoal}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          dailyPlan.when(
            data: (plan) => _SessionCard(plan: plan),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const _FallbackSessionCard(),
          ),
          const SizedBox(height: 16),
          dailyPlan.when(
            data: (plan) => _TodayMixCard(plan: plan),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final DailyPlan plan;

  const _SessionCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final nextSession =
        plan.activities.isNotEmpty ? plan.activities.first.session : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start Session',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${plan.totalActivities} blocks • ~${plan.totalEstimatedMinutes} min',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: nextSession == null
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                LessonSessionScreen(session: nextSession),
                          ),
                        ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Continue Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayMixCard extends StatelessWidget {
  final DailyPlan plan;

  const _TodayMixCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    if (plan.activities.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Session Mix',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...plan.activities.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${a.title} • ${a.estimatedMinutes} min'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackSessionCard extends StatelessWidget {
  const _FallbackSessionCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start Session',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Unable to load session plan right now.'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Continue Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

