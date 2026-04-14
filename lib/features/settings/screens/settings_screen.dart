import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/progress_repository.dart';

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DarkModeNotifier(prefs);
});

class DarkModeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  DarkModeNotifier(this._prefs)
      : super(_prefs.getBool(AppConstants.keyDarkMode) ?? false);

  Future<void> toggle() async {
    state = !state;
    await _prefs.setBool(AppConstants.keyDarkMode, state);
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);
    final auth = ref.watch(authStateProvider);
    final progress = ref.watch(userProgressProvider);
    final theme = Theme.of(context);
    const goalOptions = [20, 30, 50, 100, 150];
    final displayName = auth.displayName?.trim();
    final avatarInitial =
        (displayName != null && displayName.isNotEmpty)
            ? displayName.substring(0, 1).toUpperCase()
            : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'Account'),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(avatarInitial),
              ),
              title: Text(displayName?.isNotEmpty == true ? displayName! : 'User'),
              subtitle: Text(auth.email ?? 'Signed in'),
            ),
          ),
          const SizedBox(height: 12),
          _SectionHeader(title: 'Appearance'),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark theme'),
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
              value: isDark,
              onChanged: (_) =>
                  ref.read(darkModeProvider.notifier).toggle(),
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Learning'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.track_changes,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Daily XP Goal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current: ${progress.dailyGoal} XP/day',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: goalOptions.map((goal) {
                      final isSelected = goal == progress.dailyGoal;
                      return ChoiceChip(
                        label: Text('$goal XP'),
                        selected: isSelected,
                        onSelected: (_) => ref
                            .read(userProgressProvider.notifier)
                            .setDailyGoal(goal),
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Stats'),
          Card(
            child: Column(
              children: [
                _StatTile(
                  icon: Icons.star,
                  color: Colors.amber,
                  title: 'Total XP',
                  value: '${progress.xpPoints} XP',
                ),
                const Divider(height: 1),
                _StatTile(
                  icon: Icons.local_fire_department,
                  color: Colors.deepOrange,
                  title: 'Current Streak',
                  value: '${progress.streakDays} days',
                ),
                const Divider(height: 1),
                _StatTile(
                  icon: Icons.book,
                  color: Colors.blue,
                  title: 'Words Learned',
                  value: '${progress.wordsLearned}',
                ),
                const Divider(height: 1),
                _StatTile(
                  icon: Icons.check_circle,
                  color: Colors.green,
                  title: 'Lessons Completed',
                  value: '${progress.lessonsCompleted}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'About'),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text('Language'),
                  subtitle: Text('Bulgarian (Български)'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.school),
                  title: Text('Levels'),
                  subtitle: Text('A1 → C2 (CEFR)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.red),
            label:
                const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
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

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
      ),
    );
  }
}
