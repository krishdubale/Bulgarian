import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lesson_session_model.dart';
import '../models/user_learning_profile.dart';
import '../models/progression_policy_model.dart';
import 'srs_service.dart';
import 'progression_policy_service.dart';

final evaluationServiceProvider = Provider<EvaluationService>((ref) {
  final srsService = ref.watch(srsServiceProvider);
  final policy = ref.watch(progressionPolicyProvider);
  return EvaluationService(srsService, policy);
});

/// Evaluates session performance, updates SRS cards, and adjusts learning profiles.
class EvaluationService {
  EvaluationService(this._srsService, this._policy);

  final SrsService _srsService;
  final ProgressionPolicyService _policy;

  /// Evaluate a completed session and return results.
  Future<SessionResult> evaluateSession({
    required LessonSession session,
    required List<ExerciseResult> answers,
    required int streakDays,
  }) async {
    final correctCount = answers.where((a) => a.isCorrect).length;
    final accuracy = answers.isEmpty ? 0.0 : correctCount / answers.length;

    // Calculate XP (quality weighted).
    int xpEarned = 0;
    int criticalErrors = 0;
    for (final answer in answers) {
      if (!answer.isCorrect &&
          (answer.exerciseType == ExerciseType.translate ||
              answer.exerciseType == ExerciseType.sentenceBuild)) {
        criticalErrors++;
      }

      if (answer.isCorrect) {
        final mode = _modeFromExercise(answer.exerciseType);
        final rawXp = _policy.qualityWeightedXp(
          mode: mode,
          isCorrect: true,
          usedHints: answer.usedHint,
          retries: answer.retryCount,
        );
        xpEarned += _policy.applyDailyDiminishingReturns(
          currentTodayXp: xpEarned,
          rawAward: rawXp,
        );
      }
    }

    // Strong pass bonus.
    if (accuracy >= 0.9) xpEarned += 8;

    // Streak bonus.
    final streakBonus = streakDays >= 7 ? 10 : (streakDays >= 3 ? 5 : 0);
    xpEarned += streakBonus;

    final completionRate = session.exercises.isEmpty
        ? 0.0
        : (answers.length / session.exercises.length).clamp(0.0, 1.0);
    final hintDependence = answers.isEmpty
        ? 0.0
        : answers.where((a) => a.usedHint).length / answers.length;
    final lessonDecision = _policy.evaluateLesson(
      snapshot: LessonPerformanceSnapshot(
        score: accuracy,
        completionRate: completionRate,
        hintDependence: hintDependence,
        unresolvedCriticalErrors: criticalErrors,
      ),
      lessonNumberWithinUnit: 1,
    );

    // Identify weak and strong items.
    final weakItems = <String>[];
    final strongItems = <String>[];
    for (final answer in answers) {
      if (answer.itemId == null) continue;
      if (answer.isCorrect) {
        strongItems.add(answer.itemId!);
      } else {
        weakItems.add(answer.itemId!);
      }
    }

    // Update SRS cards for each answered item.
    for (final answer in answers) {
      if (answer.itemId == null) continue;
      final quality = _answerToQuality(answer);
      await _srsService.processAnswer(
        session.languageId,
        answer.itemId!,
        'word',
        quality,
      );
    }

    return SessionResult(
      sessionId: session.id,
      languageId: session.languageId,
      totalExercises: answers.length,
      correctAnswers: correctCount,
      accuracy: accuracy,
      xpEarned: xpEarned,
      streakBonus: streakBonus,
      timeTaken: answers.fold<Duration>(
        Duration.zero,
        (sum, a) => sum + a.responseTime,
      ),
      exerciseResults: answers,
      weakItems: weakItems,
      strongItems: strongItems,
      isPerfect: accuracy >= 1.0,
      isPassed: lessonDecision.state == LessonAttemptState.passed ||
          lessonDecision.state == LessonAttemptState.strongPass,
      isStrongPass: lessonDecision.state == LessonAttemptState.strongPass,
    );
  }

  /// Update the learning profile based on session results.
  UserLearningProfile updateProfile(
    UserLearningProfile profile,
    SessionResult result,
  ) {
    // Update topic accuracy.
    final newTopicAccuracy = Map<String, double>.from(profile.topicAccuracy);
    final newTopicAttempts = Map<String, int>.from(profile.topicAttempts);

    // Update exercise type performance.
    final newTypePerf = Map<String, int>.from(profile.exerciseTypePerformance);
    final newTypeAttempts = Map<String, int>.from(profile.exerciseTypeAttempts);

    for (final er in result.exerciseResults) {
      final typeKey = er.exerciseType.name;
      newTypeAttempts[typeKey] = (newTypeAttempts[typeKey] ?? 0) + 1;
      if (er.isCorrect) {
        newTypePerf[typeKey] = (newTypePerf[typeKey] ?? 0) + 1;
      }
    }

    // Update weak/strong word lists.
    final newWeakWords = List<String>.from(profile.weakWords);
    final newStrongWords = List<String>.from(profile.strongWords);

    for (final wId in result.weakItems) {
      if (!newWeakWords.contains(wId)) newWeakWords.add(wId);
      newStrongWords.remove(wId);
    }
    for (final sId in result.strongItems) {
      newWeakWords.remove(sId);
      if (!newStrongWords.contains(sId)) newStrongWords.add(sId);
    }

    // Update recent mistakes (keep last 20).
    final newMistakes = List<String>.from(profile.recentMistakes);
    newMistakes.addAll(result.weakItems);
    while (newMistakes.length > 20) {
      newMistakes.removeAt(0);
    }

    // Recalculate overall accuracy.
    final totalCorrectAll = newTypePerf.values.fold(0, (a, b) => a + b);
    final totalAttemptsAll = newTypeAttempts.values.fold(0, (a, b) => a + b);
    final overallAcc = totalAttemptsAll > 0
        ? (totalCorrectAll / totalAttemptsAll) * 100
        : 0.0;

    return profile.copyWith(
      topicAccuracy: newTopicAccuracy,
      topicAttempts: newTopicAttempts,
      exerciseTypePerformance: newTypePerf,
      exerciseTypeAttempts: newTypeAttempts,
      weakWords: newWeakWords,
      strongWords: newStrongWords,
      recentMistakes: newMistakes,
      totalSessions: profile.totalSessions + 1,
      overallAccuracy: overallAcc,
      lastSessionDate: DateTime.now(),
    );
  }

  /// Detect user weaknesses from their profile.
  WeaknessReport detectWeaknesses(UserLearningProfile profile) {
    // Critical words: in weak list and recent mistakes.
    final criticalWords = profile.weakWords
        .where((w) => profile.recentMistakes.contains(w))
        .toList();

    // Weak exercise types.
    final weakTypes = profile.weakExerciseTypes;

    // Recommended action.
    String action;
    if (criticalWords.length > 5) {
      action = 'review';
    } else if (profile.overallAccuracy < 60) {
      action = 'practice';
    } else {
      action = 'continue';
    }

    return WeaknessReport(
      criticalWords: criticalWords,
      weakGrammar: List<String>.from(profile.weakGrammarRules),
      suggestedExerciseTypes: weakTypes,
      recommendedAction: action,
    );
  }

  /// Whether user has mastered enough to advance to next lesson.
  bool shouldAdvance({
    required double accuracy,
    required int exerciseCount,
    double completionRate = 1.0,
    int unresolvedCriticalErrors = 0,
  }) {
    if (exerciseCount < 5) return false;
    final decision = _policy.evaluateLesson(
      snapshot: LessonPerformanceSnapshot(
        score: accuracy,
        completionRate: completionRate,
        hintDependence: 0,
        unresolvedCriticalErrors: unresolvedCriticalErrors,
      ),
      lessonNumberWithinUnit: 1,
    );
    return decision.unlockNextLesson;
  }

  /// Recommend difficulty level based on profile.
  int getRecommendedDifficulty(UserLearningProfile profile) {
    int base = 3; // default mid difficulty

    if (profile.overallAccuracy > 90) {
      base += 2;
    } else if (profile.overallAccuracy > 80) {
      base += 1;
    } else if (profile.overallAccuracy < 60) {
      base -= 1;
    } else if (profile.overallAccuracy < 40) {
      base -= 2;
    }

    return base.clamp(1, 10);
  }

  /// Convert an exercise result to SM-2 quality score (0–5).
  int _answerToQuality(ExerciseResult result) {
    if (!result.isCorrect) {
      // Wrong answer: use time to differentiate severity.
      if (result.responseTime.inSeconds < 3) return 1; // guessed wrong
      return 2; // tried but wrong
    }

    // Correct answer: distinguish by response time and type.
    if (result.responseTime.inSeconds < 3) return 5; // instant recall
    if (result.responseTime.inSeconds < 8) return 4; // good recall
    return 3; // correct but slow
  }

  SkillMode _modeFromExercise(ExerciseType type) {
    switch (type) {
      case ExerciseType.mcq:
      case ExerciseType.match:
      case ExerciseType.listening:
        return SkillMode.recognition;
      case ExerciseType.fillBlank:
        return SkillMode.recall;
      case ExerciseType.translate:
      case ExerciseType.sentenceBuild:
        return SkillMode.production;
    }
  }
}

/// Report of detected weaknesses.
class WeaknessReport {
  final List<String> criticalWords;
  final List<String> weakGrammar;
  final List<ExerciseType> suggestedExerciseTypes;
  final String recommendedAction;

  const WeaknessReport({
    required this.criticalWords,
    required this.weakGrammar,
    required this.suggestedExerciseTypes,
    required this.recommendedAction,
  });
}
