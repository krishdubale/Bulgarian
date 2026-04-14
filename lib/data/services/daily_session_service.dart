import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// Builds a single-session daily plan to maximize completion consistency.
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
    final adjustedDifficulty =
        progress.streakDays >= 7 ? (difficulty + 1).clamp(1, 10) : difficulty;

    // Daily app loop: one mixed session (review + weak-item repair + new).
    final session = await _sessionGenerator.generatePracticeSession(
      languageId: languageId,
      difficulty: adjustedDifficulty,
      profile: profile,
    );

    return DailyPlan(
      coreSession: session,
      warmup: null,
      newLesson: null,
      practice: session,
      challenge: null,
      totalEstimatedMinutes: session.targetDuration.inMinutes,
      totalActivities: 1,
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

}

/// Recommended action for the user.
enum LearningAction {
  review,
  practice,
  nextLesson,
  challenge,
}
