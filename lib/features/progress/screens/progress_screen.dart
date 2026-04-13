import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/progress_repository.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // XP and streak summary
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.star,
                  color: Colors.amber,
                  title: '${progress.xpPoints}',
                  subtitle: 'Total XP',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  color: Colors.deepOrange,
                  title: '${progress.streakDays}',
                  subtitle: 'Day Streak',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.book,
                  color: Colors.blue,
                  title: '${progress.wordsLearned}',
                  subtitle: 'Words Learned',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  color: Colors.green,
                  title: '${progress.lessonsCompleted}',
                  subtitle: 'Lessons Done',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Daily goal card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Goal',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress.dailyGoalProgress,
                            minHeight: 14,
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.2),
                            color: progress.dailyGoalProgress >= 1.0
                                ? Colors.green
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${progress.todayXp} / ${progress.dailyGoal} XP',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (progress.dailyGoalProgress >= 1.0) ...[
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.emoji_events,
                            color: Colors.amber, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Daily goal reached! 🎉',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Level progress chart
          Text(
            'XP REQUIRED PER LEVEL',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 10000,
                    barGroups: AppConstants.levels.asMap().entries.map(
                      (entry) {
                        final level = entry.value;
                        final xpNeeded =
                            AppConstants.levelXpRequirements[level]!
                                .toDouble();
                        final isCurrent = level == progress.currentLevel;
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: xpNeeded == 0 ? 50 : xpNeeded,
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary
                                      .withOpacity(0.4),
                              width: 28,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      },
                    ).toList(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final level = AppConstants.levels[value.toInt()];
                            return Text(
                              level,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: level == progress.currentLevel
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (value, meta) => Text(
                            value >= 1000
                                ? '${(value / 1000).toStringAsFixed(0)}k'
                                : value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: 2000,
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Level roadmap
          Text(
            'LEVEL ROADMAP',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...AppConstants.levels.asMap().entries.map((entry) {
            final level = entry.value;
            final xpNeeded = AppConstants.levelXpRequirements[level]!;
            final levelIdx = entry.key;
            final currentIdx =
                AppConstants.levels.indexOf(progress.currentLevel);
            final isUnlocked = levelIdx <= currentIdx;
            final isCurrent = level == progress.currentLevel;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                  width: isCurrent ? 2 : 1,
                ),
                color: isCurrent
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
                          AppConstants.levelDescriptions[level] ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isUnlocked ? null : Colors.grey,
                          ),
                        ),
                        Text(
                          xpNeeded == 0
                              ? 'Starting level'
                              : '$xpNeeded XP required',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.colorScheme.primary,
                      ),
                      child: const Text(
                        'Current',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Icon(
                      isUnlocked ? Icons.check_circle : Icons.lock,
                      color: isUnlocked ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
