/// Types of exercises available in a learning session.
enum ExerciseType {
  mcq,
  fillBlank,
  translate,
  sentenceBuild,
  listening,
}

extension ExerciseTypeCodec on ExerciseType {
  String get wire => name;

  static ExerciseType fromWire(String value) {
    return ExerciseType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => ExerciseType.mcq,
    );
  }
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

extension SessionTypeCodec on SessionType {
  String get wire => name;

  static SessionType fromWire(String value) {
    return SessionType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => SessionType.practice,
    );
  }
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.wire,
        'question': question,
        'questionTransliteration': questionTransliteration,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'hint': hint,
        'wordBank': wordBank,
        'points': points,
        'relatedItemId': relatedItemId,
        'audioFile': audioFile,
      };

  factory SessionExercise.fromJson(Map<String, dynamic> json) {
    return SessionExercise(
      id: json['id'] as String? ?? '',
      type: ExerciseTypeCodec.fromWire(json['type'] as String? ?? ''),
      question: json['question'] as String? ?? '',
      questionTransliteration: json['questionTransliteration'] as String?,
      options: List<String>.from(json['options'] as List? ?? const []),
      correctAnswer: json['correctAnswer'] as String? ?? '',
      explanation: json['explanation'] as String?,
      hint: json['hint'] as String?,
      wordBank: (json['wordBank'] as List?)?.map((e) => '$e').toList(),
      points: (json['points'] as num?)?.toInt() ?? 5,
      relatedItemId: json['relatedItemId'] as String?,
      audioFile: json['audioFile'] as String?,
    );
  }
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

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'itemId': itemId,
        'isCorrect': isCorrect,
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswer,
        'responseTimeMs': responseTime.inMilliseconds,
        'exerciseType': exerciseType.wire,
        'usedHint': usedHint,
        'retryCount': retryCount,
        'errorLabel': errorLabel,
      };

  factory ExerciseResult.fromJson(Map<String, dynamic> json) {
    return ExerciseResult(
      exerciseId: json['exerciseId'] as String? ?? '',
      itemId: json['itemId'] as String?,
      isCorrect: json['isCorrect'] as bool? ?? false,
      userAnswer: json['userAnswer'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? '',
      responseTime:
          Duration(milliseconds: (json['responseTimeMs'] as num?)?.toInt() ?? 0),
      exerciseType:
          ExerciseTypeCodec.fromWire(json['exerciseType'] as String? ?? ''),
      usedHint: json['usedHint'] as bool? ?? false,
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      errorLabel: json['errorLabel'] as String?,
    );
  }
}

/// Describes what a daily learning plan looks like.
class DailyPlan {
  final LessonSession coreSession;
  final LessonSession? warmup;
  final LessonSession? newLesson;
  final LessonSession? practice;
  final LessonSession? challenge;
  final int totalEstimatedMinutes;
  final int totalActivities;

  const DailyPlan({
    required this.coreSession,
    this.warmup,
    this.newLesson,
    this.practice,
    this.challenge,
    this.totalEstimatedMinutes = 5,
    this.totalActivities = 1,
  });

  List<DailyActivity> get activities {
    return [
      DailyActivity(
        type: SessionType.practice,
        title: 'Daily Session',
        description: 'Required session (review + weak + new)',
        session: coreSession,
        estimatedMinutes: totalEstimatedMinutes,
      ),
    ];
  }
}

extension LessonSessionCodec on LessonSession {
  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'languageId': languageId,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'difficulty': difficulty,
        'xpReward': xpReward,
        'targetDurationMs': targetDuration.inMilliseconds,
        'sessionType': sessionType.wire,
      };

  static LessonSession fromJson(Map<String, dynamic> json) {
    return LessonSession(
      id: json['id'] as String? ?? '',
      lessonId: json['lessonId'] as String? ?? '',
      languageId: json['languageId'] as String? ?? '',
      exercises: (json['exercises'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => SessionExercise.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 3,
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
      targetDuration:
          Duration(milliseconds: (json['targetDurationMs'] as num?)?.toInt() ?? 0),
      sessionType: SessionTypeCodec.fromWire(json['sessionType'] as String? ?? ''),
    );
  }
}

class SessionResumeState {
  final LessonSession session;
  final int currentIndex;
  final bool answered;
  final String? selectedAnswer;
  final List<ExerciseResult> results;
  final DateTime updatedAt;

  const SessionResumeState({
    required this.session,
    required this.currentIndex,
    required this.answered,
    required this.selectedAnswer,
    required this.results,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'session': session.toJson(),
        'currentIndex': currentIndex,
        'answered': answered,
        'selectedAnswer': selectedAnswer,
        'results': results.map((e) => e.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SessionResumeState.fromJson(Map<String, dynamic> json) {
    return SessionResumeState(
      session: LessonSessionCodec.fromJson(
        Map<String, dynamic>.from((json['session'] as Map?) ?? const {}),
      ),
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      answered: json['answered'] as bool? ?? false,
      selectedAnswer: json['selectedAnswer'] as String?,
      results: (json['results'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => ExerciseResult.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
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
