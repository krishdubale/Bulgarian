import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_learning_profile.dart';
import '../models/user_progress_model.dart';
import 'srs_service.dart';
import 'evaluation_service.dart';

final learningPathProvider = Provider<LearningPathService>((ref) {
  final srsService = ref.watch(srsServiceProvider);
  final evaluation = ref.watch(evaluationServiceProvider);
  return LearningPathService(srsService, evaluation);
});

/// Recommended action for the user.
enum PathAction { nextLesson, practice, review, challenge, rest }

/// Learning path recommendation with rationale.
class PathRecommendation {
  final PathAction action;
  final String title;
  final String description;
  final String? lessonId;
  final int estimatedMinutes;
  final int priority; // 1 = highest

  const PathRecommendation({
    required this.action,
    required this.title,
    required this.description,
    this.lessonId,
    this.estimatedMinutes = 3,
    this.priority = 1,
  });
}

/// Optimizes the learner's path through the curriculum.
/// Decides when to skip, slow down, or suggest specific actions.
class LearningPathService {
  LearningPathService(this._srsService, this._evaluationService);

  final SrsService _srsService;
  final EvaluationService _evaluationService;

  /// Get prioritized list of recommended actions.
  List<PathRecommendation> getRecommendations({
    required String languageId,
    required UserProgressModel progress,
    UserLearningProfile? profile,
  }) {
    final recommendations = <PathRecommendation>[];

    // Priority 1: Urgent SRS reviews
    final dueCount = _srsService.getDailyReviewCount(languageId);
    if (dueCount > 5) {
      recommendations.add(PathRecommendation(
        action: PathAction.review,
        title: 'Review Time',
        description: '$dueCount items need review to maintain retention.',
        estimatedMinutes: 2,
        priority: 1,
      ));
    }

    // Priority 2: Practice if struggling
    if (profile != null && profile.isStruggling) {
      recommendations.add(PathRecommendation(
        action: PathAction.practice,
        title: 'Build Confidence',
        description:
            'Let\'s practice what you\'ve learned before moving on.',
        estimatedMinutes: 3,
        priority: 2,
      ));
    }

    // Priority 3: Next lesson if ready
    final nextLessonId = _getNextUncompletedLesson(progress);
    if (nextLessonId != null) {
      final shouldProceed = profile == null || !profile.isStruggling;
      if (shouldProceed) {
        recommendations.add(PathRecommendation(
          action: PathAction.nextLesson,
          title: 'New Lesson',
          description: 'Ready for something new!',
          lessonId: nextLessonId,
          estimatedMinutes: 3,
          priority: profile?.isExcelling == true ? 1 : 3,
        ));
      }
    }

    // Priority 4: Challenge if excelling
    if (profile != null && profile.isExcelling) {
      recommendations.add(PathRecommendation(
        action: PathAction.challenge,
        title: 'Challenge Mode',
        description: 'Push your limits with harder exercises.',
        estimatedMinutes: 2,
        priority: 4,
      ));
    }

    // Priority 5: Light review
    if (dueCount > 0 && dueCount <= 5) {
      recommendations.add(PathRecommendation(
        action: PathAction.review,
        title: 'Quick Review',
        description: '$dueCount items to refresh your memory.',
        estimatedMinutes: 2,
        priority: 5,
      ));
    }

    // Sort by priority
    recommendations.sort((a, b) => a.priority.compareTo(b.priority));
    return recommendations;
  }

  /// Determine the top recommended action.
  PathRecommendation getTopRecommendation({
    required String languageId,
    required UserProgressModel progress,
    UserLearningProfile? profile,
  }) {
    final recs = getRecommendations(
      languageId: languageId,
      progress: progress,
      profile: profile,
    );

    if (recs.isEmpty) {
      return const PathRecommendation(
        action: PathAction.rest,
        title: 'All caught up!',
        description: 'Great job! Come back tomorrow for new content.',
        estimatedMinutes: 0,
      );
    }

    return recs.first;
  }

  /// Estimated time to complete current level.
  int estimatedMinutesToLevelUp({
    required UserProgressModel progress,
    required String languageId,
  }) {
    final lessonsLeft = _countRemainingLessons(progress);
    // ~3 min per lesson + review time
    return lessonsLeft * 3 + (lessonsLeft ~/ 3) * 2;
  }

  /// Calculate learning velocity (items mastered per day).
  double getLearningVelocity(UserLearningProfile profile) {
    if (profile.totalSessions == 0) return 0;
    return profile.strongWords.length / profile.totalSessions.clamp(1, 999);
  }

  String? _getNextUncompletedLesson(UserProgressModel progress) {
    const sequence = [
      'alphabet_a1',
      'greetings_a1',
      'numbers_a1',
      'grammar_sentence_a1',
      'family_a1',
      'grammar_noun_gender_a1',
      'food_a1',
      'travel_a1',
      'colors_a1',
      'animals_a1',
    ];

    for (final id in sequence) {
      if (!progress.completedLessons.contains(id)) return id;
    }
    return null;
  }

  int _countRemainingLessons(UserProgressModel progress) {
    const total = 10; // A1 lessons
    return total - progress.lessonsCompleted.clamp(0, total);
  }
}
