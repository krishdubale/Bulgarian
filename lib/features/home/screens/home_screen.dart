import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/lesson_session_model.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/services/daily_session_service.dart';
import '../../../data/services/language_manager.dart';
import '../../../data/services/session_analytics_service.dart';
import '../../../data/services/session_resume_service.dart';
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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _initializedHomeFlow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initializedHomeFlow) return;
      _initializedHomeFlow = true;
      final progress = ref.read(userProgressProvider);
      final returnBucket = progress.streakDays >= 7
          ? 'D7'
          : (progress.streakDays >= 3 ? 'D3' : 'D1');
      ref.read(sessionAnalyticsServiceProvider).logEvent('return_visit', {
        'bucket': returnBucket,
        'streakDays': progress.streakDays,
      });

      final pending = ref.read(sessionResumeServiceProvider).load();
      if (pending == null) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LessonSessionScreen(
            session: pending.session,
            resumeState: pending,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
    final nextSession = plan.coreSession;
    final label = plan.totalActivities > 1
        ? 'Continue Daily Session'
        : 'Start Daily Session';

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
              '~${plan.totalEstimatedMinutes} min • fixed daily set',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LessonSessionScreen(session: nextSession),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: Text(label),
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
