import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/progress_bar_widget.dart';
import '../../../data/models/lesson_session_model.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/services/language_manager.dart';
import '../../../data/services/daily_session_service.dart';
import '../../lesson/screens/lesson_session_screen.dart';
import '../../language/screens/language_selection_screen.dart';

/// Daily plan provider.
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium gradient app bar.
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: isDark
                ? DesignTokens.surfaceDark
                : DesignTokens.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () => context.push('/profile'),
                tooltip: 'Profile',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? DesignTokens.darkGradient
                      : DesignTokens.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
                    child: Row(
                      children: [
                        // Language selector
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const LanguageSelectionScreen(),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusFull),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(language.flag,
                                    style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 8),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      language.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      progress.levelDisplayName,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white70, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        // XP display
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(
                                DesignTokens.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: DesignTokens.xpGold, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${progress.xpPoints}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Streak & Stats ──────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _GlassStatCard(
                        icon: Icons.local_fire_department,
                        iconColor: DesignTokens.streakOrange,
                        value: '${progress.streakDays}',
                        label: 'Day Streak',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GlassStatCard(
                        icon: Icons.book_outlined,
                        iconColor: DesignTokens.info,
                        value: '${progress.wordsLearned}',
                        label: 'Words',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GlassStatCard(
                        icon: Icons.school_outlined,
                        iconColor: DesignTokens.secondary,
                        value: progress.currentLevel,
                        label: 'Level',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: DesignTokens.spacingMd),

                // ── Daily Goal ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusLg),
                    boxShadow: DesignTokens.shadowSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Goal',
                            style: theme.textTheme.titleSmall,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  DesignTokens.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusFull),
                            ),
                            child: Text(
                              '${progress.todayXp}/${progress.dailyGoal} XP',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: DesignTokens.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ProgressBarWidget(
                        value: progress.dailyGoalProgress,
                        height: 10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DesignTokens.spacingLg),

                // ── Start Learning CTA ──────────────────────────────
                dailyPlan.when(
                  data: (plan) => _buildStartButton(context, plan, theme),
                  loading: () => const Center(
                      child: CircularProgressIndicator()),
                  error: (_, __) =>
                      _buildStartButtonFallback(context, theme),
                ),

                const SizedBox(height: DesignTokens.spacingLg),

                // ── Today's Plan ────────────────────────────────────
                dailyPlan.when(
                  data: (plan) => _buildDailyPlan(context, plan, theme),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: DesignTokens.spacingLg),

                // ── Modules Grid ────────────────────────────────────
                Text(
                  'ALL MODULES',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: DesignTokens.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                  children: [
                    if (ref.watch(selectedLanguageProvider).hasAlphabet)
                      _ModuleCard(
                        icon: Icons.text_fields,
                        label: 'Alphabet',
                        color: const Color(0xFF9C27B0),
                        onTap: () => context.push('/alphabet'),
                      ),
                    _ModuleCard(
                      icon: Icons.style,
                      label: 'Vocabulary',
                      color: DesignTokens.primary,
                      onTap: () => context.go('/vocabulary'),
                    ),
                    _ModuleCard(
                      icon: Icons.menu_book,
                      label: 'Grammar',
                      color: DesignTokens.success,
                      onTap: () => context.push('/grammar'),
                    ),
                    _ModuleCard(
                      icon: Icons.record_voice_over,
                      label: 'Pronunciation',
                      color: DesignTokens.streakOrange,
                      onTap: () => context.push('/pronunciation'),
                    ),
                    _ModuleCard(
                      icon: Icons.headphones,
                      label: 'Listening',
                      color: const Color(0xFF009688),
                      onTap: () => context.push('/listening'),
                    ),
                    _ModuleCard(
                      icon: Icons.mic,
                      label: 'Speaking',
                      color: DesignTokens.accent,
                      onTap: () => context.push('/speaking'),
                    ),
                    _ModuleCard(
                      icon: Icons.auto_stories,
                      label: 'Reading',
                      color: const Color(0xFF3F51B5),
                      onTap: () => context.push('/reading'),
                    ),
                    _ModuleCard(
                      icon: Icons.edit_note,
                      label: 'Writing',
                      color: const Color(0xFF795548),
                      onTap: () => context.push('/writing'),
                    ),
                    _ModuleCard(
                      icon: Icons.bar_chart,
                      label: 'Progress',
                      color: const Color(0xFF00BCD4),
                      onTap: () => context.go('/progress'),
                    ),
                  ],
                ),

                const SizedBox(height: DesignTokens.spacingLg),

                // ── Level Roadmap ───────────────────────────────────
                Text(
                  'LEVEL ROADMAP',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: DesignTokens.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...AppConstants.levels.map((level) {
                  final isCurrentLevel = level == progress.currentLevel;
                  final levelIndex = AppConstants.levels.indexOf(level);
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
                const SizedBox(height: DesignTokens.spacingLg),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(
      BuildContext context, DailyPlan plan, ThemeData theme) {
    final firstSession = plan.activities.isNotEmpty
        ? plan.activities.first.session
        : null;

    return Container(
      decoration: BoxDecoration(
        gradient: DesignTokens.primaryGradient,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        boxShadow: DesignTokens.glowPrimary,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: firstSession == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          LessonSessionScreen(session: firstSession),
                    ),
                  ),
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingLg,
                vertical: DesignTokens.spacingLg),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: DesignTokens.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Today\'s Lesson',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '~${plan.totalEstimatedMinutes} min • ${plan.totalActivities} activities',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButtonFallback(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: DesignTokens.primaryGradient,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/vocabulary'),
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          child: const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingLg,
                vertical: DesignTokens.spacingLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Start Learning',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyPlan(
      BuildContext context, DailyPlan plan, ThemeData theme) {
    final activities = plan.activities;
    if (activities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TODAY\'S PLAN',
          style: theme.textTheme.labelSmall?.copyWith(
            color: DesignTokens.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ...activities.asMap().entries.map((entry) {
          final idx = entry.key;
          final activity = entry.value;
          return _DailyActivityTile(
            activity: activity,
            index: idx,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    LessonSessionScreen(session: activity.session),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Glass-morphism style stat card.
class _GlassStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _GlassStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DailyActivityTile extends StatelessWidget {
  final DailyActivity activity;
  final int index;
  final VoidCallback onTap;

  const _DailyActivityTile({
    required this.activity,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconMap = {
      SessionType.warmup: Icons.refresh,
      SessionType.lesson: Icons.school,
      SessionType.practice: Icons.fitness_center,
      SessionType.challenge: Icons.emoji_events,
      SessionType.review: Icons.history,
    };
    final colorMap = {
      SessionType.warmup: DesignTokens.secondary,
      SessionType.lesson: DesignTokens.primary,
      SessionType.practice: DesignTokens.streakOrange,
      SessionType.challenge: DesignTokens.xpGold,
      SessionType.review: DesignTokens.info,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: InkWell(
          onTap: activity.isCompleted ? null : onTap,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: activity.isCompleted
                    ? DesignTokens.success.withOpacity(0.3)
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (colorMap[activity.type] ?? DesignTokens.primary)
                        .withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    activity.isCompleted
                        ? Icons.check
                        : (iconMap[activity.type] ?? Icons.play_arrow),
                    color: activity.isCompleted
                        ? DesignTokens.success
                        : (colorMap[activity.type] ?? DesignTokens.primary),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          decoration: activity.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      Text(
                        '${activity.estimatedMinutes} min • ${activity.description}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (!activity.isCompleted)
                  Icon(Icons.chevron_right,
                      color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
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
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            boxShadow: DesignTokens.shadowSm,
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
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
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: isCurrentLevel
              ? DesignTokens.primary
              : theme.dividerColor,
          width: isCurrentLevel ? 2 : 1,
        ),
        color: isCurrentLevel
            ? DesignTokens.primary.withOpacity(0.06)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? DesignTokens.primary.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                level,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? DesignTokens.primary : Colors.grey,
                ),
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
                      color: DesignTokens.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            isUnlocked ? Icons.lock_open_outlined : Icons.lock_outlined,
            color: isUnlocked ? DesignTokens.success : Colors.grey,
            size: 18,
          ),
        ],
      ),
    );
  }
}
