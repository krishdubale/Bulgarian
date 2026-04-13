import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lesson_session_model.dart';
import '../models/user_learning_profile.dart';
import '../models/user_progress_model.dart';
import 'session_generator.dart';
import 'evaluation_service.dart';
import 'srs_service.dart';


final learningLoopProvider = Provider<LearningLoopService>((ref) {
  final sessionGen = ref.watch(sessionGeneratorProvider);
  final evaluation = ref.watch(evaluationServiceProvider);
  final srsService = ref.watch(srsServiceProvider);
  return LearningLoopService(sessionGen, evaluation, srsService);
});

/// Learning loop stages.
enum LoopStage { learn, practice, test, reinforce, review }

/// Result of processing a completed stage.
class StageResult {
  final LoopStage completedStage;
  final LoopStage? nextStage;
  final SessionResult? sessionResult;
  final bool shouldRepeat;
  final bool shouldAdvance;
  final String? message;
  final int xpEarned;

  const StageResult({
    required this.completedStage,
    this.nextStage,
    this.sessionResult,
    this.shouldRepeat = false,
    this.shouldAdvance = false,
    this.message,
    this.xpEarned = 0,
  });
}

/// Failure handling result.
class FailureAction {
  final List<String> itemsToRequeue;
  final String explanation;
  final int reducedDifficulty;
  final bool showTutorial;

  const FailureAction({
    required this.itemsToRequeue,
    required this.explanation,
    required this.reducedDifficulty,
    this.showTutorial = false,
  });
}

/// Central orchestrator for the 5-stage learning loop.
///
/// Loop flow:
/// ```
/// LEARN → PRACTICE → TEST → REINFORCE → REVIEW
/// (New)    (Mixed)   (Score)  (Mistakes)   (SRS)
/// ```
///
/// Progression rules:
/// - Advance: accuracy ≥ 70% on ≥ 5 exercises
/// - Repeat: accuracy < 50%
/// - 3 consecutive wrong → show explanation, re-queue with lower interval
class LearningLoopService {
  LearningLoopService(
    this._sessionGenerator,
    this._evaluationService,
    this._srsService,
  );

  final SessionGenerator _sessionGenerator;
  final EvaluationService _evaluationService;
  final SrsService _srsService;

  /// Determine the current loop stage based on session type.
  LoopStage stageFromSessionType(SessionType type) {
    switch (type) {
      case SessionType.lesson:
        return LoopStage.learn;
      case SessionType.practice:
        return LoopStage.practice;
      case SessionType.challenge:
        return LoopStage.test;
      case SessionType.review:
        return LoopStage.review;
      case SessionType.warmup:
        return LoopStage.review;
    }
  }

  /// Get the next stage in the loop.
  LoopStage? getNextStage(LoopStage current, SessionResult result) {
    final accuracy = result.accuracy;

    switch (current) {
      case LoopStage.learn:
        return LoopStage.practice;
      case LoopStage.practice:
        return LoopStage.test;
      case LoopStage.test:
        if (accuracy < 0.5) {
          // Failed test — go back to reinforce
          return LoopStage.reinforce;
        }
        if (result.weakItems.isNotEmpty) {
          return LoopStage.reinforce;
        }
        return LoopStage.review;
      case LoopStage.reinforce:
        return LoopStage.review;
      case LoopStage.review:
        return null; // Loop complete
    }
  }

  /// Process a completed session and determine next action.
  Future<StageResult> processCompletedSession({
    required LessonSession session,
    required List<ExerciseResult> answers,
    required UserProgressModel progress,
    UserLearningProfile? profile,
  }) async {
    final result = await _evaluationService.evaluateSession(
      session: session,
      answers: answers,
      streakDays: progress.streakDays,
    );

    final stage = stageFromSessionType(session.sessionType);
    final nextStage = getNextStage(stage, result);

    // Check progression
    final shouldAdvance = _evaluationService.shouldAdvance(
      accuracy: result.accuracy,
      exerciseCount: result.totalExercises,
    );

    // Check if repeat needed
    final shouldRepeat = result.accuracy < 0.5 && result.totalExercises >= 3;

    // Build message
    String? message;
    if (result.isPerfect) {
      message = 'Perfect score! You\'re ready to move on! 🎉';
    } else if (shouldAdvance) {
      message = 'Great work! New content unlocked! 🚀';
    } else if (shouldRepeat) {
      message = 'Let\'s practice this a bit more. You\'ll get it! 💪';
    } else if (result.weakItems.isNotEmpty) {
      message =
          '${result.weakItems.length} items need review. Keep going! 📚';
    }

    return StageResult(
      completedStage: stage,
      nextStage: nextStage,
      sessionResult: result,
      shouldRepeat: shouldRepeat,
      shouldAdvance: shouldAdvance,
      message: message,
      xpEarned: result.xpEarned,
    );
  }

  /// Generate the next session based on current stage and results.
  Future<LessonSession?> generateNextSession({
    required LoopStage stage,
    required String languageId,
    required int difficulty,
    required UserProgressModel progress,
    SessionResult? previousResult,
    UserLearningProfile? profile,
  }) async {
    switch (stage) {
      case LoopStage.learn:
        final nextLessonId = _getNextLessonId(progress);
        if (nextLessonId == null) return null;
        return _sessionGenerator.generateLessonSession(
          languageId: languageId,
          lessonId: nextLessonId,
          difficulty: difficulty,
          profile: profile,
        );

      case LoopStage.practice:
        return _sessionGenerator.generatePracticeSession(
          languageId: languageId,
          difficulty: difficulty,
          profile: profile,
        );

      case LoopStage.test:
        return _sessionGenerator.generateChallengeSession(
          languageId: languageId,
          difficulty: difficulty,
        );

      case LoopStage.reinforce:
        // Generate session focused on weak items from previous result
        return _sessionGenerator.generatePracticeSession(
          languageId: languageId,
          difficulty: (difficulty - 1).clamp(1, 10),
          profile: profile,
        );

      case LoopStage.review:
        return _sessionGenerator.generateWarmupSession(
          languageId: languageId,
        );
    }
  }

  /// Handle consecutive failures for an item.
  FailureAction handleConsecutiveFailures({
    required List<ExerciseResult> recentAnswers,
    required int currentDifficulty,
  }) {
    // Find items with 3+ consecutive wrong answers
    final failCounts = <String, int>{};
    for (final answer in recentAnswers) {
      if (!answer.isCorrect && answer.itemId != null) {
        failCounts[answer.itemId!] = (failCounts[answer.itemId!] ?? 0) + 1;
      }
    }

    final criticalItems = failCounts.entries
        .where((e) => e.value >= 3)
        .map((e) => e.key)
        .toList();

    if (criticalItems.isEmpty) {
      return FailureAction(
        itemsToRequeue: [],
        explanation: 'Keep trying! Mistakes help you learn.',
        reducedDifficulty: currentDifficulty,
      );
    }

    return FailureAction(
      itemsToRequeue: criticalItems,
      explanation:
          'These ${criticalItems.length} items need extra attention. '
          'We\'ll show them again with hints.',
      reducedDifficulty: (currentDifficulty - 2).clamp(1, 10),
      showTutorial: true,
    );
  }

  /// Check if user should advance to the next lesson.
  bool shouldAdvanceToNextLesson({
    required double accuracy,
    required int exerciseCount,
    required int consecutivePerfect,
  }) {
    // Standard: 70% accuracy on 5+ exercises
    if (accuracy >= 0.7 && exerciseCount >= 5) return true;
    // Fast-track: 2 consecutive perfect sessions
    if (consecutivePerfect >= 2) return true;
    return false;
  }

  /// Get recommended difficulty based on profile and recent performance.
  int getRecommendedDifficulty({
    UserLearningProfile? profile,
    double? recentAccuracy,
  }) {
    if (profile != null) {
      return _evaluationService.getRecommendedDifficulty(profile);
    }
    if (recentAccuracy != null) {
      if (recentAccuracy > 0.9) return 6;
      if (recentAccuracy > 0.7) return 4;
      if (recentAccuracy > 0.5) return 3;
      return 2;
    }
    return 3;
  }

  String? _getNextLessonId(UserProgressModel progress) {
    // This will be replaced by curriculum-driven progression
    // For now, use lesson index
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
    return null;
  }
}
