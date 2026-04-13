import 'lesson_session_model.dart';

/// Deep learning profile tracking per-user, per-language performance.
class UserLearningProfile {
  final String userId;
  final String languageId;
  final Map<String, double> topicAccuracy; // topic -> accuracy %
  final Map<String, int> topicAttempts; // topic -> total attempts
  final Map<String, Duration> avgResponseTime; // topic -> avg time
  final List<String> weakWords;
  final List<String> strongWords;
  final List<String> weakGrammarRules;
  final Map<String, int> exerciseTypePerformance; // ExerciseType.name -> correct count
  final Map<String, int> exerciseTypeAttempts; // ExerciseType.name -> total attempts
  final int totalSessions;
  final double overallAccuracy;
  final DateTime lastSessionDate;
  final List<String> recentMistakes; // last 20 mistake item IDs

  const UserLearningProfile({
    required this.userId,
    required this.languageId,
    this.topicAccuracy = const {},
    this.topicAttempts = const {},
    this.avgResponseTime = const {},
    this.weakWords = const [],
    this.strongWords = const [],
    this.weakGrammarRules = const [],
    this.exerciseTypePerformance = const {},
    this.exerciseTypeAttempts = const {},
    this.totalSessions = 0,
    this.overallAccuracy = 0,
    required this.lastSessionDate,
    this.recentMistakes = const [],
  });

  factory UserLearningProfile.initial({
    required String userId,
    required String languageId,
  }) {
    return UserLearningProfile(
      userId: userId,
      languageId: languageId,
      lastSessionDate: DateTime.now(),
    );
  }

  /// Get accuracy for a specific exercise type.
  double exerciseTypeAccuracy(ExerciseType type) {
    final key = type.name;
    final attempts = exerciseTypeAttempts[key] ?? 0;
    if (attempts == 0) return 0;
    return ((exerciseTypePerformance[key] ?? 0) / attempts) * 100;
  }

  /// Get the exercise types the user struggles with most.
  List<ExerciseType> get weakExerciseTypes {
    final types = ExerciseType.values.toList();
    types.sort((a, b) {
      final accA = exerciseTypeAccuracy(a);
      final accB = exerciseTypeAccuracy(b);
      return accA.compareTo(accB); // worst first
    });
    return types.where((t) => exerciseTypeAccuracy(t) < 70).toList();
  }

  /// Whether user is currently struggling (needs easier content).
  bool get isStruggling => overallAccuracy < 50 && totalSessions >= 3;

  /// Whether user is performing well (can handle harder content).
  bool get isExcelling => overallAccuracy > 85 && totalSessions >= 3;

  UserLearningProfile copyWith({
    String? userId,
    String? languageId,
    Map<String, double>? topicAccuracy,
    Map<String, int>? topicAttempts,
    Map<String, Duration>? avgResponseTime,
    List<String>? weakWords,
    List<String>? strongWords,
    List<String>? weakGrammarRules,
    Map<String, int>? exerciseTypePerformance,
    Map<String, int>? exerciseTypeAttempts,
    int? totalSessions,
    double? overallAccuracy,
    DateTime? lastSessionDate,
    List<String>? recentMistakes,
  }) {
    return UserLearningProfile(
      userId: userId ?? this.userId,
      languageId: languageId ?? this.languageId,
      topicAccuracy: topicAccuracy ?? this.topicAccuracy,
      topicAttempts: topicAttempts ?? this.topicAttempts,
      avgResponseTime: avgResponseTime ?? this.avgResponseTime,
      weakWords: weakWords ?? this.weakWords,
      strongWords: strongWords ?? this.strongWords,
      weakGrammarRules: weakGrammarRules ?? this.weakGrammarRules,
      exerciseTypePerformance:
          exerciseTypePerformance ?? this.exerciseTypePerformance,
      exerciseTypeAttempts:
          exerciseTypeAttempts ?? this.exerciseTypeAttempts,
      totalSessions: totalSessions ?? this.totalSessions,
      overallAccuracy: overallAccuracy ?? this.overallAccuracy,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      recentMistakes: recentMistakes ?? this.recentMistakes,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'languageId': languageId,
        'topicAccuracy': topicAccuracy,
        'topicAttempts': topicAttempts,
        'avgResponseTime': avgResponseTime.map(
          (k, v) => MapEntry(k, v.inMilliseconds),
        ),
        'weakWords': weakWords,
        'strongWords': strongWords,
        'weakGrammarRules': weakGrammarRules,
        'exerciseTypePerformance': exerciseTypePerformance,
        'exerciseTypeAttempts': exerciseTypeAttempts,
        'totalSessions': totalSessions,
        'overallAccuracy': overallAccuracy,
        'lastSessionDate': lastSessionDate.toIso8601String(),
        'recentMistakes': recentMistakes,
      };

  factory UserLearningProfile.fromJson(Map<String, dynamic> json) {
    final responseTimeMap = <String, Duration>{};
    final rawTimes = json['avgResponseTime'] as Map<String, dynamic>? ?? {};
    rawTimes.forEach((k, v) {
      responseTimeMap[k] = Duration(milliseconds: (v as num).toInt());
    });

    return UserLearningProfile(
      userId: json['userId'] as String? ?? '',
      languageId: json['languageId'] as String? ?? 'bg',
      topicAccuracy: Map<String, double>.from(
        (json['topicAccuracy'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v as num).toDouble()),
            ) ??
            {},
      ),
      topicAttempts: Map<String, int>.from(
        (json['topicAttempts'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v as num).toInt()),
            ) ??
            {},
      ),
      avgResponseTime: responseTimeMap,
      weakWords: List<String>.from(json['weakWords'] as List? ?? []),
      strongWords: List<String>.from(json['strongWords'] as List? ?? []),
      weakGrammarRules:
          List<String>.from(json['weakGrammarRules'] as List? ?? []),
      exerciseTypePerformance: Map<String, int>.from(
        (json['exerciseTypePerformance'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v as num).toInt()),
            ) ??
            {},
      ),
      exerciseTypeAttempts: Map<String, int>.from(
        (json['exerciseTypeAttempts'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v as num).toInt()),
            ) ??
            {},
      ),
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      overallAccuracy: (json['overallAccuracy'] as num?)?.toDouble() ?? 0,
      lastSessionDate: json['lastSessionDate'] != null
          ? DateTime.parse(json['lastSessionDate'] as String)
          : DateTime.now(),
      recentMistakes:
          List<String>.from(json['recentMistakes'] as List? ?? []),
    );
  }
}
