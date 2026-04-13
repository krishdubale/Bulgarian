import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lesson_session_model.dart';
import '../models/user_learning_profile.dart';
import '../models/user_progress_model.dart';
import 'session_generator.dart';
import 'evaluation_service.dart';
import 'srs_service.dart';

final dailySessionServiceProvider = Provider<DailySessionService>((ref) {
  final sessionGen = ref.watch(sessionGeneratorProvider);
  final evaluation = ref.watch(evaluationServiceProvider);
  final srsService = ref.watch(srsServiceProvider);
  return DailySessionService(sessionGen, evaluation, srsService);
});

/// Orchestrates the daily user learning experience.
/// Builds a DailyPlan with warm-up, lesson, practice, and challenge sessions.
class DailySessionService {
  DailySessionService(
    this._sessionGenerator,
    this._evaluationService,
    this._srsService,
  );

  final SessionGenerator _sessionGenerator;
  final EvaluationService _evaluationService;
  final SrsService _srsService;

  /// Build today's daily plan for a user.
  Future<DailyPlan> getDailyPlan({
    required String languageId,
    required UserProgressModel progress,
    UserLearningProfile? profile,
  }) async {
    final difficulty = profile != null
        ? _evaluationService.getRecommendedDifficulty(profile)
        : 3;

    // 1. Repair: urgent mistakes/high-risk due items.
    LessonSession? warmup;
    final urgentCount = _srsService.getUrgentCards(languageId, limit: 5).length;
    final dueCount = _srsService.getDailyReviewCount(languageId);
    if (urgentCount > 0 || dueCount > 0) {
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

    // 3. Review: delayed retrieval from weak + due items.
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
      totalMinutes += 3;
      totalActivities++;
    }
    if (newLesson != null) {
      totalMinutes += 6;
      totalActivities++;
    }
    totalMinutes += 6; // review/practice always exists
    totalActivities++;
    totalMinutes += 2; // micro-check/challenge
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
    // Priority 1: Repair urgent weak items.
    final urgentCount = _srsService.getUrgentCards(languageId, limit: 5).length;
    if (urgentCount > 0) {
      return LearningAction.review;
    }

    // Priority 2: Review if SRS items are due.
    final dueCount = _srsService.getDailyReviewCount(languageId);
    if (dueCount > 3) {
      return LearningAction.review;
    }

    // Priority 3: Practice if struggling.
    if (profile != null && profile.isStruggling) {
      return LearningAction.practice;
    }

    // Priority 4: Continue with lessons.
    return LearningAction.nextLesson;
  }

  /// Determine the next lesson ID based on progress.
  String? _getNextLessonId(UserProgressModel progress) {
    // Basic lesson sequence — expandable later with curriculum.
    const lessonSequence = [
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

    for (final lessonId in lessonSequence) {
      if (!progress.completedLessons.contains(lessonId)) {
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
