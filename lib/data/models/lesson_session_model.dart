/// Types of exercises available in a learning session.
enum ExerciseType {
  mcq,
  fillBlank,
  match,
  translate,
  sentenceBuild,
  listening,
}

/// A complete interactive learning session.
class LessonSession {
  final String id;
  final String lessonId;
  final String languageId;
  final List<SessionExercise> exercises;
  final int difficulty; // 1–10
  final int xpReward;
  final Duration targetDuration;
  final SessionType sessionType;

  const LessonSession({
    required this.id,
    required this.lessonId,
    required this.languageId,
    required this.exercises,
    required this.difficulty,
    required this.xpReward,
    this.targetDuration = const Duration(minutes: 3),
    this.sessionType = SessionType.lesson,
  });
}

/// Category of session — determines content mixing strategy.
enum SessionType {
  warmup,    // SRS review items
  lesson,    // New content
  practice,  // Mixed weak + new items
  challenge, // Higher difficulty bonus
  review,    // Weekly/daily review
}

/// A single exercise within a session.
class SessionExercise {
  final String id;
  final ExerciseType type;
  final String question;
  final String? questionTransliteration;
  final List<String> options; // for MCQ/match
  final String correctAnswer;
  final String? explanation;
  final String? hint;
  final List<String>? wordBank; // for sentence building
  final int points;
  final String? relatedItemId; // word/grammar id being tested
  final String? audioFile;

  const SessionExercise({
    required this.id,
    required this.type,
    required this.question,
    this.questionTransliteration,
    this.options = const [],
    required this.correctAnswer,
    this.explanation,
    this.hint,
    this.wordBank,
    this.points = 5,
    this.relatedItemId,
    this.audioFile,
  });
}

/// Result of a completed session.
class SessionResult {
  final String sessionId;
  final String languageId;
  final int totalExercises;
  final int correctAnswers;
  final double accuracy;
  final int xpEarned;
  final int streakBonus;
  final Duration timeTaken;
  final List<ExerciseResult> exerciseResults;
  final List<String> weakItems; // items to reinforce
  final List<String> strongItems; // items mastered
  final bool isPerfect;
  final bool isPassed;
  final bool isStrongPass;

  const SessionResult({
    required this.sessionId,
    required this.languageId,
    required this.totalExercises,
    required this.correctAnswers,
    required this.accuracy,
    required this.xpEarned,
    this.streakBonus = 0,
    required this.timeTaken,
    required this.exerciseResults,
    this.weakItems = const [],
    this.strongItems = const [],
    this.isPerfect = false,
    this.isPassed = false,
    this.isStrongPass = false,
  });
}

/// Result of a single exercise attempt.
class ExerciseResult {
  final String exerciseId;
  final String? itemId; // the word/grammar being tested
  final bool isCorrect;
  final String userAnswer;
  final String correctAnswer;
  final Duration responseTime;
  final ExerciseType exerciseType;
  final bool usedHint;
  final int retryCount;
  final String? errorLabel;

  const ExerciseResult({
    required this.exerciseId,
    this.itemId,
    required this.isCorrect,
    required this.userAnswer,
    required this.correctAnswer,
    required this.responseTime,
    required this.exerciseType,
    this.usedHint = false,
    this.retryCount = 0,
    this.errorLabel,
  });
}

/// Describes what a daily learning plan looks like.
class DailyPlan {
  final LessonSession? warmup;
  final LessonSession? newLesson;
  final LessonSession? practice;
  final LessonSession? challenge;
  final int totalEstimatedMinutes;
  final int totalActivities;

  const DailyPlan({
    this.warmup,
    this.newLesson,
    this.practice,
    this.challenge,
    this.totalEstimatedMinutes = 5,
    this.totalActivities = 4,
  });

  List<DailyActivity> get activities {
    final list = <DailyActivity>[];
    if (warmup != null) {
      list.add(DailyActivity(
        type: SessionType.warmup,
        title: 'Warm-up Review',
        description: 'Review previous words',
        session: warmup!,
        estimatedMinutes: 2,
      ));
    }
    if (newLesson != null) {
      list.add(DailyActivity(
        type: SessionType.lesson,
        title: 'New Lesson',
        description: 'Learn something new',
        session: newLesson!,
        estimatedMinutes: 3,
      ));
    }
    if (practice != null) {
      list.add(DailyActivity(
        type: SessionType.practice,
        title: 'Practice',
        description: 'Strengthen your skills',
        session: practice!,
        estimatedMinutes: 2,
      ));
    }
    if (challenge != null) {
      list.add(DailyActivity(
        type: SessionType.challenge,
        title: 'Bonus Challenge',
        description: 'Push your limits',
        session: challenge!,
        estimatedMinutes: 2,
      ));
    }
    return list;
  }
}

/// A single activity within the daily plan.
class DailyActivity {
  final SessionType type;
  final String title;
  final String description;
  final LessonSession session;
  final int estimatedMinutes;
  final bool isCompleted;

  const DailyActivity({
    required this.type,
    required this.title,
    required this.description,
    required this.session,
    this.estimatedMinutes = 3,
    this.isCompleted = false,
  });

  DailyActivity markCompleted() => DailyActivity(
        type: type,
        title: title,
        description: description,
        session: session,
        estimatedMinutes: estimatedMinutes,
        isCompleted: true,
      );
}
