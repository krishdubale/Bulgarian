import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lesson_session_model.dart';
import '../models/user_learning_profile.dart';
import 'srs_service.dart';
import 'content_loader.dart';

final adaptiveEngineProvider = Provider<AdaptiveEngine>((ref) {
  final srsService = ref.watch(srsServiceProvider);
  final contentLoader = ref.watch(contentLoaderProvider);
  return AdaptiveEngine(srsService, contentLoader);
});

/// Content mix ratios for different learner profiles.
class ContentMix {
  final double newContentRatio;
  final double reviewRatio;
  final double weakItemsRatio;
  final int targetExerciseCount;
  final List<ExerciseType> preferredTypes;

  const ContentMix({
    required this.newContentRatio,
    required this.reviewRatio,
    required this.weakItemsRatio,
    this.targetExerciseCount = 6,
    this.preferredTypes = const [],
  });
}

/// Adaptive session configuration based on user performance.
class AdaptiveConfig {
  final ContentMix mix;
  final int difficulty;
  final Duration targetDuration;
  final String rationale;

  const AdaptiveConfig({
    required this.mix,
    required this.difficulty,
    this.targetDuration = const Duration(minutes: 3),
    required this.rationale,
  });
}

/// Generates personalized session configurations based on user performance.
class AdaptiveEngine {
  AdaptiveEngine(this._srsService, this._contentLoader);

  final SrsService _srsService;
  final ContentLoader _contentLoader;
  final _random = Random();

  /// Generate adaptive configuration for a user.
  AdaptiveConfig getAdaptiveConfig({
    required String languageId,
    required UserLearningProfile profile,
  }) {
    final dueCount = _srsService.getDailyReviewCount(languageId);
    final weakItems = _srsService.getWeakItems(languageId, count: 20);

    if (profile.isStruggling) {
      return AdaptiveConfig(
        mix: ContentMix(
          newContentRatio: 0.2,
          reviewRatio: 0.4,
          weakItemsRatio: 0.4,
          targetExerciseCount: 5,
          preferredTypes: _getEasierTypes(),
        ),
        difficulty: _clampDifficulty(2),
        targetDuration: const Duration(minutes: 2),
        rationale: 'Focusing on review and weak items to build confidence.',
      );
    }

    if (profile.isExcelling) {
      return AdaptiveConfig(
        mix: ContentMix(
          newContentRatio: 0.5,
          reviewRatio: 0.2,
          weakItemsRatio: 0.3,
          targetExerciseCount: 8,
          preferredTypes: _getHarderTypes(),
        ),
        difficulty: _clampDifficulty(7),
        targetDuration: const Duration(minutes: 4),
        rationale: 'Great performance! Introducing more new content.',
      );
    }

    // Normal learner
    if (dueCount > 10) {
      // Urgent review needed
      return AdaptiveConfig(
        mix: ContentMix(
          newContentRatio: 0.2,
          reviewRatio: 0.5,
          weakItemsRatio: 0.3,
          targetExerciseCount: 7,
        ),
        difficulty: _clampDifficulty(4),
        rationale: 'Many items due for review. Prioritizing SRS queue.',
      );
    }

    return AdaptiveConfig(
      mix: ContentMix(
        newContentRatio: 0.4,
        reviewRatio: 0.3,
        weakItemsRatio: 0.3,
        targetExerciseCount: 6,
      ),
      difficulty: _clampDifficulty(4),
      rationale: 'Balanced mix of new content and review.',
    );
  }

  /// Determine preferred exercise types based on user weaknesses.
  /// Gives more practice on types the user struggles with.
  List<ExerciseType> getExerciseTypeWeights(UserLearningProfile profile) {
    final weakTypes = profile.weakExerciseTypes;
    final types = <ExerciseType>[];

    for (final type in ExerciseType.values) {
      final accuracy = profile.exerciseTypeAccuracy(type);
      if (accuracy < 50) {
        // Very weak: include 3x for more practice
        types.addAll([type, type, type]);
      } else if (accuracy < 70) {
        // Weak: include 2x
        types.addAll([type, type]);
      } else {
        // Good: include 1x
        types.add(type);
      }
    }

    if (types.isEmpty) return ExerciseType.values.toList();
    return types;
  }

  /// Calculate optimal session length based on user behavior.
  Duration getOptimalSessionLength(UserLearningProfile profile) {
    // If user has short attention span (low sessions, quick times)
    if (profile.totalSessions > 5) {
      final avgResponseTime = profile.avgResponseTime.values.fold<Duration>(
        Duration.zero,
        (a, b) => a + b,
      );
      final avgMs = profile.avgResponseTime.isNotEmpty
          ? avgResponseTime.inMilliseconds ~/ profile.avgResponseTime.length
          : 5000;

      if (avgMs < 3000) {
        return const Duration(minutes: 2); // Fast responder
      }
      if (avgMs > 10000) {
        return const Duration(minutes: 5); // Slower, more thoughtful
      }
    }
    return const Duration(minutes: 3); // Default
  }

  /// Score how well a user knows a specific topic.
  double getTopicMastery(UserLearningProfile profile, String topic) {
    final accuracy = profile.topicAccuracy[topic] ?? 0;
    final attempts = profile.topicAttempts[topic] ?? 0;

    if (attempts < 3) return 0; // Not enough data

    // Factor in both accuracy and volume
    final volumeFactor = min(1.0, attempts / 10.0);
    return accuracy * volumeFactor;
  }

  /// Check if a topic should be skipped (mastered).
  bool isTopicMastered(
    UserLearningProfile profile,
    String topic,
    String languageId,
  ) {
    final mastery = getTopicMastery(profile, topic);
    if (mastery < 85) return false;

    // Also check SRS: if all related items have easeFactor > 3.0
    final cards = _srsService.loadCards(languageId);
    final topicCards = cards.values.where(
      (c) => c.itemId.contains(topic.toLowerCase()),
    );
    if (topicCards.isEmpty) return false;

    return topicCards.every((c) => c.easeFactor > 3.0 && c.interval > 14);
  }

  List<ExerciseType> _getEasierTypes() => [
        ExerciseType.mcq,
        ExerciseType.mcq,
        ExerciseType.match,
        ExerciseType.fillBlank,
      ];

  List<ExerciseType> _getHarderTypes() => [
        ExerciseType.translate,
        ExerciseType.sentenceBuild,
        ExerciseType.fillBlank,
        ExerciseType.listening,
      ];

  int _clampDifficulty(int d) => d.clamp(1, 10);
}
