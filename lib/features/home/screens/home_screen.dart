import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/progress_bar_widget.dart';
import '../../../data/repositories/progress_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.75),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          child: Text(
                            progress.currentLevel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome back! 🇧🇬',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                progress.levelDisplayName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            Text(
                              '${progress.xpPoints} XP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Streak & daily goal row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department,
                        iconColor: Colors.deepOrange,
                        title: '${progress.streakDays} day streak',
                        subtitle: 'Keep it up!',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.book_outlined,
                        iconColor: Colors.blue,
                        title: '${progress.wordsLearned} words',
                        subtitle: 'learned so far',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Daily goal card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daily Goal',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${progress.todayXp} / ${progress.dailyGoal} XP',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ProgressBarWidget(
                          value: progress.dailyGoalProgress,
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'LEARN',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Module grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                  children: [
                    _ModuleCard(
                      icon: Icons.text_fields,
                      label: 'Alphabet',
                      color: Colors.purple,
                      onTap: () => context.push('/alphabet'),
                    ),
                    _ModuleCard(
                      icon: Icons.style,
                      label: 'Vocabulary',
                      color: Colors.blue,
                      onTap: () => context.go('/vocabulary'),
                    ),
                    _ModuleCard(
                      icon: Icons.menu_book,
                      label: 'Grammar',
                      color: Colors.green,
                      onTap: () => context.push('/grammar'),
                    ),
                    _ModuleCard(
                      icon: Icons.record_voice_over,
                      label: 'Pronunciation',
                      color: Colors.orange,
                      onTap: () => context.push('/pronunciation'),
                    ),
                    _ModuleCard(
                      icon: Icons.headphones,
                      label: 'Listening',
                      color: Colors.teal,
                      onTap: () => context.push('/listening'),
                    ),
                    _ModuleCard(
                      icon: Icons.mic,
                      label: 'Speaking',
                      color: Colors.red,
                      onTap: () => context.push('/speaking'),
                    ),
                    _ModuleCard(
                      icon: Icons.auto_stories,
                      label: 'Reading',
                      color: Colors.indigo,
                      onTap: () => context.push('/reading'),
                    ),
                    _ModuleCard(
                      icon: Icons.edit,
                      label: 'Writing',
                      color: Colors.brown,
                      onTap: () => context.push('/writing'),
                    ),
                    _ModuleCard(
                      icon: Icons.bar_chart,
                      label: 'Progress',
                      color: Colors.cyan,
                      onTap: () => context.go('/progress'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'LEVELS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...AppConstants.levels.map((level) {
                  final isCurrentLevel = level == progress.currentLevel;
                  final levelIndex =
                      AppConstants.levels.indexOf(level);
                  final currentIndex =
                      AppConstants.levels.indexOf(progress.currentLevel);
                  final isUnlocked = levelIndex <= currentIndex;
                  return _LevelRow(
                    level: level,
                    description:
                        AppConstants.levelDescriptions[level] ?? '',
                    isCurrentLevel: isCurrentLevel,
                    isUnlocked: isUnlocked,
                  );
                }),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  final String level;
  final String description;
  final bool isCurrentLevel;
  final bool isUnlocked;

  const _LevelRow({
    required this.level,
    required this.description,
    required this.isCurrentLevel,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentLevel
              ? theme.colorScheme.primary
              : theme.dividerColor,
          width: isCurrentLevel ? 2 : 1,
        ),
        color: isCurrentLevel
            ? theme.colorScheme.primary.withOpacity(0.08)
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isUnlocked
                ? theme.colorScheme.primary.withOpacity(0.15)
                : Colors.grey.withOpacity(0.15),
            child: Text(
              level,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isUnlocked
                    ? theme.colorScheme.primary
                    : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
                if (isCurrentLevel)
                  Text(
                    '← Current level',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            isUnlocked ? Icons.lock_open_outlined : Icons.lock_outlined,
            color: isUnlocked ? Colors.green : Colors.grey,
            size: 18,
          ),
        ],
      ),
    );
  }
}
