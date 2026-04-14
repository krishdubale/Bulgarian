import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../models/lesson_session_model.dart';
import '../models/user_learning_profile.dart';
import '../models/user_progress_model.dart';
import 'session_generator.dart';
import 'evaluation_service.dart';
import 'srs_service.dart';
import 'progression_policy_service.dart';
import '../models/progression_policy_model.dart';

final dailySessionServiceProvider = Provider<DailySessionService>((ref) {
  final sessionGen = ref.watch(sessionGeneratorProvider);
  final evaluation = ref.watch(evaluationServiceProvider);
  final srsService = ref.watch(srsServiceProvider);
  final policy = ref.watch(progressionPolicyProvider);
  return DailySessionService(sessionGen, evaluation, srsService, policy);
});

/// Orchestrates the daily user learning experience.
/// Builds a DailyPlan with warm-up, lesson, practice, and challenge sessions.
class DailySessionService {
  DailySessionService(
    this._sessionGenerator,
    this._evaluationService,
    this._srsService,
    this._policy,
  );

  final SessionGenerator _sessionGenerator;
  final EvaluationService _evaluationService;
  final SrsService _srsService;
  final ProgressionPolicyService _policy;

  /// Build today's daily plan for a user.
  Future<DailyPlan> getDailyPlan({
    required String languageId,
    required UserProgressModel progress,
    UserLearningProfile? profile,
  }) async {
    final difficulty = profile != null
        ? _evaluationService.getRecommendedDifficulty(profile)
        : 3;

    // 1. Warm-up: review SRS due items.
    LessonSession? warmup;
    final dueCount = _srsService.getDailyReviewCount(languageId);
    if (dueCount > 0) {
      warmup = await _sessionGenerator.generateWarmupSession(
        languageId: languageId,
      );
    }

    // 2. New lesson: generate from next uncompleted lesson.
    final nextLessonId = _getNextLessonId(progress);
    LessonSession? newLesson;
    if (nextLessonId != null) {
      newLesson = await _sessionGenerator.generateLessonSession(
        languageId: languageId,
        lessonId: nextLessonId,
        difficulty: difficulty,
        profile: profile,
      );
    }

    // 3. Practice: mix weak and new items.
    final practice = await _sessionGenerator.generatePracticeSession(
      languageId: languageId,
      difficulty: difficulty,
      profile: profile,
    );

    // 4. Challenge: optional harder session.
    final challenge = await _sessionGenerator.generateChallengeSession(
      languageId: languageId,
      difficulty: difficulty,
    );

    int totalMinutes = 0;
    int totalActivities = 0;
    if (warmup != null) {
      totalMinutes += 2;
      totalActivities++;
    }
    if (newLesson != null) {
      totalMinutes += 3;
      totalActivities++;
    }
    totalMinutes += 2; // practice always exists
    totalActivities++;
    totalMinutes += 2; // challenge
    totalActivities++;

    return DailyPlan(
      warmup: warmup,
      newLesson: newLesson,
      practice: practice,
      challenge: challenge,
      totalEstimatedMinutes: totalMinutes,
      totalActivities: totalActivities,
    );
  }

  /// Get the next recommended action for the user.
  LearningAction getNextAction({
    required UserProgressModel progress,
    UserLearningProfile? profile,
    required String languageId,
  }) {
    final weakCards = _srsService.getWeakItems(languageId, count: 12);
    final weakCount = weakCards.length;
    final requiredRepairBlocks = _policy.requiredRepairBlocks(
      WeakAreaReport(
        weakSkills: weakCards.map((c) => c.itemId).toList(),
        severe: weakCount >= _policy.severeWeakQueueThreshold,
      ),
    );
    if (requiredRepairBlocks > 0) {
      return LearningAction.practice;
    }

    // Priority 1: Review if SRS items are due.
    final dueCount = _srsService.getDailyReviewCount(languageId);
    if (dueCount > 3) {
      return LearningAction.review;
    }

    // Priority 2: Practice if struggling.
    if (profile != null && profile.isStruggling) {
      return LearningAction.practice;
    }

    // Priority 3: Continue with lessons.
    return LearningAction.nextLesson;
  }

  /// Determine the next lesson ID based on progress.
  String? _getNextLessonId(UserProgressModel progress) {
    for (final lessonId in AppConstants.defaultLessonSequence) {
      if (!progress.completedLessons.contains(lessonId) &&
          progress.unlockedLessons.contains(lessonId)) {
        return lessonId;
      }
    }
    return null; // all lessons completed
  }
}

/// Recommended action for the user.
enum LearningAction {
  review,
  practice,
  nextLesson,
  challenge,
}
