import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lesson_session_model.dart';
import '../models/srs_model.dart';
import '../models/user_learning_profile.dart';
import 'srs_service.dart';

final evaluationServiceProvider = Provider<EvaluationService>((ref) {
  final srsService = ref.watch(srsServiceProvider);
  return EvaluationService(srsService);
});

/// Evaluates session performance, updates SRS cards, and adjusts learning profiles.
class EvaluationService {
  EvaluationService(this._srsService);

  final SrsService _srsService;

  /// Evaluate a completed session and return results.
  Future<SessionResult> evaluateSession({
    required LessonSession session,
    required List<ExerciseResult> answers,
    required int streakDays,
  }) async {
    final correctCount = answers.where((a) => a.isCorrect).length;
    final accuracy = answers.isEmpty ? 0.0 : correctCount / answers.length;

    int xpEarned = 0;
    final weakItems = <String>{};
    final strongItems = <String>{};
    final mistakes = <MistakeRecord>[];

    for (final answer in answers) {
      final exercise = session.exercises.firstWhere(
        (e) => e.id == answer.exerciseId,
        orElse: () => session.exercises.first,
      );

      if (answer.itemId == null) {
        xpEarned += _xpForAnswer(
          answer: answer,
          exercise: exercise,
          card: null,
        );
        continue;
      }

      final itemId = answer.itemId!;
      final card = _srsService.getOrCreateCard(session.languageId, itemId, 'word');
      final quality = _answerToQuality(
        answer,
        exerciseType: answer.exerciseType,
        previousCard: card,
      );

      await _srsService.processAnswer(
        session.languageId,
        itemId,
        'word',
        quality,
      );

      xpEarned += _xpForAnswer(
        answer: answer,
        exercise: exercise,
        card: card,
      );

      if (answer.isCorrect) {
        if (!weakItems.contains(itemId)) {
          strongItems.add(itemId);
        }
      } else {
        strongItems.remove(itemId);
        weakItems.add(itemId);
      }

      final taggedError = answer.errorType ?? _tagError(answer);
      if (!answer.isCorrect || _isFragileCorrect(answer)) {
        mistakes.add(MistakeRecord(
          atomId: itemId,
          exerciseType: answer.exerciseType,
          errorType: taggedError,
          userResponse: answer.userAnswer,
          expectedResponse: answer.correctAnswer,
          latency: answer.responseTime,
          hintsUsed: answer.hintsUsed,
          timestamp: DateTime.now(),
          contextSentenceId: answer.contextSentenceId,
          severityScore: _severityScore(
            answer: answer,
            card: card,
            quality: quality,
          ),
        ));
      }
    }

    if (accuracy >= 0.9) xpEarned += 4;
    if (accuracy >= 1.0) xpEarned += 4;
    final streakBonus = streakDays >= 7 ? 8 : (streakDays >= 3 ? 4 : 0);
    xpEarned += streakBonus;

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
      weakItems: weakItems.toList(),
      strongItems: strongItems.toList(),
      mistakes: mistakes,
      isPerfect: accuracy >= 1.0,
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
  }) {
    return accuracy >= 0.7 && exerciseCount >= 5;
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

    return (base.clamp(1, 10)) as int;
  }

  /// Convert an exercise result to SM-2 quality score (0–5).
  int _answerToQuality(
    ExerciseResult result, {
    required ExerciseType exerciseType,
    SrsCard? previousCard,
  }) {
    if (!result.isCorrect) {
      if (result.attempts > 1 || result.hintsUsed > 0) return 2;
      return 1;
    }

    final expectedSeconds = _expectedLatency(exerciseType);
    final ratio = expectedSeconds == 0
        ? 1.0
        : result.responseTime.inMilliseconds / (expectedSeconds * 1000);

    var quality = 4;
    if (ratio <= 0.7 && result.hintsUsed == 0 && result.attempts <= 1) {
      quality = 5;
    } else if (ratio > 1.35 || result.hintsUsed > 0 || result.attempts > 1) {
      quality = 3;
    }

    if (previousCard != null && previousCard.overdueDays >= 3 && quality >= 4) {
      quality = 5;
    }
    return quality;
  }

  int _xpForAnswer({
    required ExerciseResult answer,
    required SessionExercise exercise,
    required SrsCard? card,
  }) {
    final base = exercise.points;
    final typeWeight = _typeWeight(answer.exerciseType);
    final latencySeconds = answer.responseTime.inMilliseconds / 1000;
    final expectedSeconds = _expectedLatency(answer.exerciseType).toDouble();
    final speedFactor = (expectedSeconds / (latencySeconds + 0.5)).clamp(0.6, 1.25);
    final hintPenalty = (answer.hintsUsed * 0.12).clamp(0.0, 0.35);
    final attemptPenalty = ((answer.attempts - 1) * 0.08).clamp(0.0, 0.25);

    var xp = base * typeWeight;
    if (answer.isCorrect) {
      xp *= (speedFactor - hintPenalty - attemptPenalty).clamp(0.45, 1.35);
      if (card != null && card.totalReviews == 0) xp += 2; // novelty stabilize bonus
      if (card != null && card.overdueDays > 0) xp += 1; // overdue recovery bonus
    } else {
      xp *= 0.1;
    }
    return (xp.round().clamp(0, 30)) as int;
  }

  bool _isFragileCorrect(ExerciseResult answer) {
    if (!answer.isCorrect) return false;
    return answer.hintsUsed > 0 || answer.attempts > 1 || answer.responseTime.inSeconds >= 12;
  }

  int _severityScore({
    required ExerciseResult answer,
    required SrsCard card,
    required int quality,
  }) {
    var severity = 3;
    if (!answer.isCorrect) severity += 3;
    severity += (answer.hintsUsed.clamp(0, 2)) as int;
    if (answer.responseTime.inSeconds > 12) severity += 1;
    if (card.failureStreak >= 2) severity += 2;
    if (quality <= 1) severity += 1;
    return (severity.clamp(1, 10)) as int;
  }

  ErrorType _tagError(ExerciseResult result) {
    if (!result.isCorrect && result.userAnswer.trim().isEmpty) {
      return ErrorType.recallFailure;
    }

    final expected = result.correctAnswer.trim().toLowerCase();
    final got = result.userAnswer.trim().toLowerCase();

    switch (result.exerciseType) {
      case ExerciseType.mcq:
      case ExerciseType.match:
        return ErrorType.comprehension;
      case ExerciseType.fillBlank:
        if (_looksLikeSameStem(got, expected)) return ErrorType.morphology;
        return ErrorType.orthography;
      case ExerciseType.translate:
        if (_looksLikeWordOrderIssue(got, expected)) return ErrorType.syntax;
        return ErrorType.comprehension;
      case ExerciseType.sentenceBuild:
        return ErrorType.syntax;
      case ExerciseType.listening:
        return ErrorType.phonology;
    }
  }

  bool _looksLikeSameStem(String got, String expected) {
    if (got.isEmpty || expected.isEmpty) return false;
    final shortest = got.length < expected.length ? got.length : expected.length;
    if (shortest < 3) return false;
    return got.substring(0, 3) == expected.substring(0, 3) && got != expected;
  }

  bool _looksLikeWordOrderIssue(String got, String expected) {
    if (got == expected) return false;
    final gotWords = got.split(RegExp(r'\s+'))..sort();
    final expectedWords = expected.split(RegExp(r'\s+'))..sort();
    return gotWords.join(' ') == expectedWords.join(' ');
  }

  double _typeWeight(ExerciseType type) {
    switch (type) {
      case ExerciseType.mcq:
        return 0.8;
      case ExerciseType.match:
        return 0.85;
      case ExerciseType.fillBlank:
        return 1.0;
      case ExerciseType.translate:
        return 1.2;
      case ExerciseType.sentenceBuild:
        return 1.1;
      case ExerciseType.listening:
        return 1.15;
    }
  }

  int _expectedLatency(ExerciseType type) {
    switch (type) {
      case ExerciseType.mcq:
      case ExerciseType.match:
        return 4;
      case ExerciseType.fillBlank:
        return 7;
      case ExerciseType.translate:
      case ExerciseType.sentenceBuild:
        return 10;
      case ExerciseType.listening:
        return 8;
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
