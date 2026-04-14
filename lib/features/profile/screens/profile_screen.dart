import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/repositories/progress_repository.dart';
import '../../../core/constants/app_constants.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final progress = ref.watch(userProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      (auth.displayName ?? 'U')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.displayName ?? 'User',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    auth.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Text(
                      progress.levelDisplayName,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats grid
          _SectionHeader(title: 'Learning Statistics'),
          Row(
            children: [
              Expanded(
                child: _ProfileStatCard(
                  icon: Icons.star,
                  color: Colors.amber,
                  value: '${progress.xpPoints}',
                  label: 'Total XP',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStatCard(
                  icon: Icons.local_fire_department,
                  color: Colors.deepOrange,
                  value: '${progress.streakDays}',
                  label: 'Day Streak',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ProfileStatCard(
                  icon: Icons.book,
                  color: Colors.blue,
                  value: '${progress.wordsLearned}',
                  label: 'Words Learned',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStatCard(
                  icon: Icons.check_circle,
                  color: Colors.green,
                  value: '${progress.lessonsCompleted}',
                  label: 'Lessons Done',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ProfileStatCard(
                  icon: Icons.quiz,
                  color: Colors.purple,
                  value: '${progress.completedLessons.length}',
                  label: 'Quizzes Passed',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStatCard(
                  icon: Icons.track_changes,
                  color: Colors.teal,
                  value: '${progress.todayXp}/${progress.dailyGoal}',
                  label: 'Daily Goal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Level progress
          _SectionHeader(title: 'Level Progress'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...AppConstants.levels.map((level) {
                    final xpNeeded =
                        AppConstants.levelXpRequirements[level]!;
                    final currentIdx = AppConstants.levels
                        .indexOf(progress.currentLevel);
                    final levelIdx = AppConstants.levels.indexOf(level);
                    final isUnlocked = levelIdx <= currentIdx;
                    final isCurrent = level == progress.currentLevel;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isCurrent
                            ? theme.colorScheme.primary.withOpacity(0.08)
                            : null,
                        border: isCurrent
                            ? Border.all(
                                color: theme.colorScheme.primary, width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isUnlocked
                                ? Icons.check_circle
                                : Icons.lock_outline,
                            color: isUnlocked
                                ? (isCurrent
                                    ? theme.colorScheme.primary
                                    : Colors.green)
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$level — ${AppConstants.levelDescriptions[level]}',
                            style: TextStyle(
                              fontWeight:
                                  isCurrent ? FontWeight.bold : null,
                              color: isUnlocked ? null : Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$xpNeeded XP',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Sign Out',
                  style: TextStyle(color: Colors.red)),
              onPressed: () {
                ref.read(authStateProvider.notifier).logout();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _ProfileStatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
