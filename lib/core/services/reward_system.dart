import 'package:flutter_riverpod/flutter_riverpod.dart';

final rewardSystemProvider = Provider<RewardSystem>((ref) {
  return RewardSystem();
});

/// Types of achievement milestones.
enum MilestoneType {
  firstLesson,
  tenLessons,
  fiftyLessons,
  hundredWords,
  fiveHundredWords,
  thousandWords,
  weekStreak,
  monthStreak,
  yearStreak,
  perfectSession,
  tenPerfect,
  languageUnlock,
  levelUp,
}

/// A celebration event to display.
class CelebrationEvent {
  final MilestoneType type;
  final String title;
  final String description;
  final String emoji;
  final int bonusXp;

  const CelebrationEvent({
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    this.bonusXp = 0,
  });
}

/// XP reward rules for different actions.
class XpRewardRules {
  static const int lessonComplete = 10;
  static const int reviewComplete = 5;
  static const int perfectSessionBonus = 15;
  static const int streakDay = 5;
  static const int streakWeekBonus = 20;
  static const int streakMonthBonus = 50;
  static const int wordLearned = 3;
  static const int challengeWin = 20;
  static const int milestoneBonus = 25;
}

/// Manages rewards, XP rules, and milestone celebrations.
class RewardSystem {
  /// Check if any milestones are reached and return celebration events.
  List<CelebrationEvent> checkMilestones({
    required int lessonsCompleted,
    required int wordsLearned,
    required int streakDays,
    required int perfectSessions,
    required int languagesStarted,
    required String currentLevel,
    Set<MilestoneType> alreadyAwarded = const {},
  }) {
    final celebrations = <CelebrationEvent>[];

    // Lesson milestones
    if (lessonsCompleted >= 1 &&
        !alreadyAwarded.contains(MilestoneType.firstLesson)) {
      celebrations.add(const CelebrationEvent(
        type: MilestoneType.firstLesson,
        title: 'First Steps!',
        description: 'You completed your first lesson!',
        emoji: '🎓',
        bonusXp: 10,
      ));
    }

    if (lessonsCompleted >= 10 &&
        !alreadyAwarded.contains(MilestoneType.tenLessons)) {
      celebrations.add(const CelebrationEvent(
        type: MilestoneType.tenLessons,
        title: 'Getting Serious!',
        description: '10 lessons completed!',
        emoji: '📚',
        bonusXp: 25,
      ));
    }

    if (lessonsCompleted >= 50 &&
        !alreadyAwarded.contains(MilestoneType.fiftyLessons)) {
      celebrations.add(const CelebrationEvent(
        type: MilestoneType.fiftyLessons,
        title: 'Dedicated Learner!',
        description: '50 lessons completed!',
        emoji: '🏆',
        bonusXp: 50,
      ));
    }

    // Word milestones
    if (wordsLearned >= 100 &&
        !alreadyAwarded.contains(MilestoneType.hundredWords)) {
      celebrations.add(const CelebrationEvent(
        type: MilestoneType.hundredWords,
        title: 'Word Collector!',
        description: 'You know 100 words!',
        emoji: '💯',
        bonusXp: 30,
      ));
    }

    if (wordsLearned >= 500 &&
        !alreadyAwarded.contains(MilestoneType.fiveHundredWords)) {
      celebrations.add(const CelebrationEvent(
        type: MilestoneType.fiveHundredWords,
        title: 'Vocabulary Master!',
        description: '500 words and counting!',
        emoji: '🌟',
        bonusXp: 75,
      ));
    }

    if (wordsLearned >= 1000 &&
        !alreadyAwarded.contains(MilestoneType.thousandWords)) {
      celebrations.add(const CelebrationEvent(
        type: MilestoneType.thousandWords,
        title: 'Polyglot Power!',
        description: '1000 words mastered!',
        emoji: '🔥',
        bonusXp: 150,
      ));
    }

    // Streak milestones
    if (streakDays >= 7 &&
        !alreadyAwarded.contains(MilestoneType.weekStreak)) {
      celebrations.add(const CelebrationEvent(
        type: MilestoneType.weekStreak,
        title: 'Week Warrior!',
        description: '7-day streak! Keep it going!',
        emoji: '⚡',
        bonusXp: 20,
      ));
    }

    if (streakDays >= 30 &&
        !alreadyAwarded.contains(MilestoneType.monthStreak)) {
      celebrations.add(const CelebrationEvent(
        type: MilestoneType.monthStreak,
        title: 'Monthly Champion!',
        description: '30-day streak! Incredible dedication!',
        emoji: '👑',
        bonusXp: 50,
      ));
    }

    return celebrations;
  }

  /// Calculate XP for a completed session.
  int calculateSessionXp({
    required int correctAnswers,
    required int totalExercises,
    required int difficulty,
    required int streakDays,
    required bool isPerfect,
  }) {
    int xp = 0;

    // Base XP per correct answer
    xp += correctAnswers * 3;

    // Difficulty bonus
    xp += difficulty * 2;

    // Accuracy bonus tiers
    final accuracy =
        totalExercises > 0 ? correctAnswers / totalExercises : 0.0;
    if (accuracy >= 1.0) xp += XpRewardRules.perfectSessionBonus;
    else if (accuracy >= 0.9) xp += 10;
    else if (accuracy >= 0.8) xp += 5;

    // Streak bonus
    if (streakDays >= 30) xp += 10;
    else if (streakDays >= 7) xp += 5;
    else if (streakDays >= 3) xp += 2;

    return xp.clamp(5, 100);
  }

  /// Get the level name for a given XP total.
  String getLevelForXp(int xp) {
    if (xp >= 9000) return 'C2';
    if (xp >= 5500) return 'C1';
    if (xp >= 3000) return 'B2';
    if (xp >= 1500) return 'B1';
    if (xp >= 500) return 'A2';
    return 'A1';
  }

  /// Get numeric level (1-50) for gamification display.
  int getNumericLevel(int xp) {
    return (xp / 100).floor() + 1;
  }

  /// XP needed for next numeric level.
  int xpToNextLevel(int xp) {
    final currentLevel = getNumericLevel(xp);
    return (currentLevel * 100) - xp;
  }
}
