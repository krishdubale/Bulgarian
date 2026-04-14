import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/progression_policy_model.dart';

final progressionPolicyProvider = Provider<ProgressionPolicyService>((ref) {
  return const ProgressionPolicyService();
});

class ProgressionPolicyService {
  const ProgressionPolicyService();

  static const double passCompletionThreshold = 0.90;
  static const double passScoreThreshold = 0.75;
  static const int passCriticalErrorLimit = 2;
  static const int _severeWeakQueueThreshold = 4;
  static const int _smallDueReviewThreshold = 3;
  static const double subskillPassThreshold = 0.70;
  static const double reviewHoldRetentionThreshold = 0.70;

  int get severeWeakQueueThreshold => _severeWeakQueueThreshold;

  LessonEvaluationDecision evaluateLesson({
    required LessonPerformanceSnapshot snapshot,
    required int lessonNumberWithinUnit,
  }) {
    final passed = snapshot.completionRate >= passCompletionThreshold &&
        snapshot.score >= passScoreThreshold &&
        snapshot.unresolvedCriticalErrors <= passCriticalErrorLimit;

    final strongPass = passed &&
        snapshot.score >= 0.90 &&
        snapshot.completionRate >= 0.95 &&
        snapshot.hintDependence <= 0.20 &&
        snapshot.unresolvedCriticalErrors == 0;

    final state = strongPass
        ? LessonAttemptState.strongPass
        : (passed ? LessonAttemptState.passed : LessonAttemptState.attempted);

    return LessonEvaluationDecision(
      state: state,
      unlockNextLesson: passed,
      requiresReviewGate: lessonNumberWithinUnit % 3 == 0,
      requiresUnitReview: lessonNumberWithinUnit == 6,
    );
  }

  bool shouldRequireUnitCheckpoint({
    required bool unitReviewPassed,
  }) {
    return unitReviewPassed;
  }

  UnitJumpTestDecision evaluateUnitJumpTest({
    required double score,
    required List<double> subskillScores,
  }) {
    final allSectionsPassed =
        subskillScores.every((s) => s >= subskillPassThreshold);
    final passed = score >= 0.85 && allSectionsPassed;
    return UnitJumpTestDecision(
      passed: passed,
      requiresResumeAtFirstNotMastered: !passed,
    );
  }

  bool shouldApplyReviewHold({
    required double priorUnitRetention,
    double threshold = reviewHoldRetentionThreshold,
  }) {
    return priorUnitRetention < threshold;
  }

  WeakAreaReport detectWeakAreas({
    required Map<String, double> recentAccuracy,
    required Map<String, int> sameErrorTypeMistakesIn7Days,
    required Map<String, double> retentionScores,
    required Map<String, double> latencyRatioToBaseline,
    int severeWeakCountThreshold = _severeWeakQueueThreshold,
  }) {
    final weak = <String>{};

    recentAccuracy.forEach((skill, acc) {
      if (acc < 0.70) weak.add(skill);
    });
    sameErrorTypeMistakesIn7Days.forEach((skill, mistakes) {
      if (mistakes >= 3) weak.add(skill);
    });
    retentionScores.forEach((skill, score) {
      if (score < 0.70) weak.add(skill);
    });
    latencyRatioToBaseline.forEach((skill, ratio) {
      if (ratio > 1.8) weak.add(skill);
    });

    return WeakAreaReport(
      weakSkills: weak.toList(),
      severe: weak.length >= severeWeakCountThreshold,
    );
  }

  int requiredRepairBlocks(WeakAreaReport report) {
    if (report.weakSkills.isEmpty) return 0;
    return report.severe ? 2 : 1;
  }

  PracticeSessionMix practiceSessionMix({required bool severeWeakQueue}) {
    return severeWeakQueue
        ? const PracticeSessionMix(newItems: 2, reviewItems: 9, repairItems: 4)
        : const PracticeSessionMix(newItems: 4, reviewItems: 7, repairItems: 4);
  }

  bool sessionSuccessful({
    required double accuracy,
    required bool criticalWeakItemsAttempted,
    required bool productiveModeSuccessOnFocusTargets,
  }) {
    return accuracy >= 0.75 &&
        criticalWeakItemsAttempted &&
        productiveModeSuccessOnFocusTargets;
  }

  SessionPathType nextSessionType({
    required bool severeWeakQueue,
    required bool highDueLoad,
  }) {
    if (severeWeakQueue) return SessionPathType.repair;
    if (highDueLoad) return SessionPathType.review;
    return SessionPathType.advance;
  }

  bool grantProgressCredit({required bool requiredReviewQuotaSatisfied}) {
    return requiredReviewQuotaSatisfied;
  }

  int qualityWeightedXp({
    required SkillMode mode,
    required bool isCorrect,
    required bool usedHints,
    required int retries,
    bool overdueRetentionWin = false,
    bool trivialRepeat = false,
  }) {
    if (!isCorrect || trivialRepeat) return 0;

    final modeWeight = switch (mode) {
      SkillMode.recognition => 2,
      SkillMode.recall => 4,
      SkillMode.production => 6,
      SkillMode.transfer => 8,
    };

    int xp = modeWeight;
    if (usedHints) xp = (xp * 0.6).round();
    if (retries > 0) xp = (xp * (1 / (retries + 1))).round().clamp(1, xp);
    if (overdueRetentionWin) xp += 2;
    return xp;
  }

  int applyDailyDiminishingReturns({
    required int currentTodayXp,
    required int rawAward,
    int masteryTargetQuota = 120,
  }) {
    if (rawAward <= 0) return 0;
    if (currentTodayXp < masteryTargetQuota) return rawAward;
    return (rawAward * 0.5).round().clamp(1, rawAward);
  }

  bool qualifiesForStreakDay({
    required int passedLessonsCompleted,
    required int reviewBlocksCompleted,
    required int dueReviewCount,
    required int dueReviewsCompleted,
  }) {
    if (passedLessonsCompleted < 1) return false;
    if (dueReviewCount <= _smallDueReviewThreshold) {
      return dueReviewsCompleted >= dueReviewCount;
    }
    return reviewBlocksCompleted >= 1;
  }
}
