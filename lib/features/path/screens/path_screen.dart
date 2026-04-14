import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/repositories/progress_repository.dart';

class PathScreen extends ConsumerWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final currentIndex = AppConstants.levels.indexOf(progress.currentLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Path'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Progression',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Read-only progression view. Continue your next session to advance.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...AppConstants.levels.asMap().entries.map((entry) {
            final idx = entry.key;
            final level = entry.value;
            final unlocked = idx <= currentIndex;
            final current = level == progress.currentLevel;

            return Card(
              child: ListTile(
                leading: Icon(
                  current
                      ? Icons.play_circle_fill
                      : (unlocked ? Icons.check_circle : Icons.lock),
                  color: current
                      ? Theme.of(context).colorScheme.primary
                      : (unlocked ? Colors.green : Colors.grey),
                ),
                title: Text(
                  '$level — ${AppConstants.levelDescriptions[level]}',
                  style: TextStyle(
                    fontWeight: current ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  '${AppConstants.levelXpRequirements[level]} XP',
                ),
                trailing: current
                    ? const Text('Current')
                    : (unlocked ? const Text('Done') : const Text('Locked')),
              ),
            );
          }),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Continue Session'),
            ),
          ),
        ],
      ),
    );
  }
}

