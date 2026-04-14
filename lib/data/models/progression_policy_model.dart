enum LessonAttemptState {
  attempted,
  passed,
  strongPass,
}

enum SkillMode {
  recognition,
  recall,
  production,
  transfer,
}

enum SessionPathType {
  advance,
  repair,
  review,
}

class LessonPerformanceSnapshot {
  final double score; // 0..1
  final double completionRate; // 0..1
  final double hintDependence; // 0..1
  final int unresolvedCriticalErrors;
  final Map<String, int> errorProfile;

  const LessonPerformanceSnapshot({
    required this.score,
    required this.completionRate,
    required this.hintDependence,
    this.unresolvedCriticalErrors = 0,
    this.errorProfile = const {},
  });
}

class LessonEvaluationDecision {
  final LessonAttemptState state;
  final bool unlockNextLesson;
  final bool requiresReviewGate;
  final bool requiresUnitReview;

  const LessonEvaluationDecision({
    required this.state,
    required this.unlockNextLesson,
    this.requiresReviewGate = false,
    this.requiresUnitReview = false,
  });
}

class WeakAreaReport {
  final List<String> weakSkills;
  final bool severe;

  const WeakAreaReport({
    this.weakSkills = const [],
    this.severe = false,
  });
}

class PracticeSessionMix {
  final int newItems;
  final int reviewItems;
  final int repairItems;

  const PracticeSessionMix({
    required this.newItems,
    required this.reviewItems,
    required this.repairItems,
  });

  int get total => newItems + reviewItems + repairItems;
}

class UnitJumpTestDecision {
  final bool passed;
  final bool requiresResumeAtFirstNotMastered;

  const UnitJumpTestDecision({
    required this.passed,
    this.requiresResumeAtFirstNotMastered = false,
  });
}

