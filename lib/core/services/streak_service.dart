import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/app_providers.dart';
import 'progression_policy_service.dart';


final streakServiceProvider = Provider<StreakService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final policy = ref.watch(progressionPolicyProvider);
  return StreakService(prefs, policy);
});

/// Streak milestone thresholds.
const streakMilestones = [3, 7, 14, 30, 60, 100, 365];

/// Streak update result.
class StreakUpdate {
  final int newStreak;
  final bool isNewMilestone;
  final int? milestone;
  final bool usedFreeze;
  final bool wasReset;
  final int freezesRemaining;
  final int bonusXp;

  const StreakUpdate({
    required this.newStreak,
    this.isNewMilestone = false,
    this.milestone,
    this.usedFreeze = false,
    this.wasReset = false,
    this.freezesRemaining = 0,
    this.bonusXp = 0,
  });
}

/// Manages daily streak tracking with freeze support.
class StreakService {
  StreakService(this._prefs, this._policy);

  final SharedPreferences _prefs;
  final ProgressionPolicyService _policy;
  static const _freezeKey = 'streak_freeze_count';
  static const _lastActiveKey = 'streak_last_active_date';
  static const _longestStreakKey = 'longest_streak';
  static const _maxFreezes = 3;

  /// Get current freeze count.
  int get freezeCount => _prefs.getInt(_freezeKey) ?? _maxFreezes;

  /// Get longest streak ever.
  int get longestStreak => _prefs.getInt(_longestStreakKey) ?? 0;

  /// Process daily login and update streak.
  StreakUpdate processLogin({
    required int currentStreak,
    required DateTime lastLoginDate,
  }) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastDate = DateTime(
      lastLoginDate.year,
      lastLoginDate.month,
      lastLoginDate.day,
    );
    final daysDiff = todayDate.difference(lastDate).inDays;

    if (daysDiff == 0) {
      // Same day — no change
      return StreakUpdate(
        newStreak: currentStreak,
        freezesRemaining: freezeCount,
      );
    }

    if (daysDiff == 1) {
      // Consecutive day — increment streak
      final newStreak = currentStreak + 1;
      _updateLongest(newStreak);
      final milestone = _checkMilestone(newStreak);

      int bonusXp = 0;
      if (milestone != null) {
        bonusXp = milestone * 2; // Milestone bonus scales with milestone
      }

      return StreakUpdate(
        newStreak: newStreak,
        isNewMilestone: milestone != null,
        milestone: milestone,
        freezesRemaining: freezeCount,
        bonusXp: bonusXp,
      );
    }

    // Missed day(s)
    if (daysDiff == 2 && freezeCount > 0) {
      // Use streak freeze for 1 missed day
      final newFreezeCount = freezeCount - 1;
      _prefs.setInt(_freezeKey, newFreezeCount);

      return StreakUpdate(
        newStreak: currentStreak + 1, // Continue streak
        usedFreeze: true,
        freezesRemaining: newFreezeCount,
      );
    }

    // Reset streak
    return StreakUpdate(
      newStreak: 1,
      wasReset: true,
      freezesRemaining: freezeCount,
    );
  }

  /// Award a streak freeze (earned through perfect sessions).
  Future<void> awardFreeze() async {
    final current = freezeCount;
    if (current < _maxFreezes) {
      await _prefs.setInt(_freezeKey, current + 1);
    }
  }

  /// Reset freeze count to max (monthly refresh).
  Future<void> refreshFreezes() async {
    await _prefs.setInt(_freezeKey, _maxFreezes);
  }

  bool qualifiesStreakDay({
    required int passedLessonsCompleted,
    required int reviewBlocksCompleted,
    required int dueReviewCount,
    required int dueReviewsCompleted,
  }) {
    return _policy.qualifiesForStreakDay(
      passedLessonsCompleted: passedLessonsCompleted,
      reviewBlocksCompleted: reviewBlocksCompleted,
      dueReviewCount: dueReviewCount,
      dueReviewsCompleted: dueReviewsCompleted,
    );
  }

  void _updateLongest(int current) {
    if (current > longestStreak) {
      _prefs.setInt(_longestStreakKey, current);
    }
  }

  int? _checkMilestone(int streak) {
    for (final m in streakMilestones) {
      if (streak == m) return m;
    }
    return null;
  }
}
