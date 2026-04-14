class Progress {
  final String userId;
  final String languageId;
  final String currentUnitId;
  final String currentLessonId;
  final int xp;
  final int streak;
  final Map<String, int> skillStates;

  const Progress({
    required this.userId,
    required this.languageId,
    required this.currentUnitId,
    required this.currentLessonId,
    this.xp = 0,
    this.streak = 0,
    this.skillStates = const {},
  });

  Progress copyWith({
    String? userId,
    String? languageId,
    String? currentUnitId,
    String? currentLessonId,
    int? xp,
    int? streak,
    Map<String, int>? skillStates,
  }) {
    return Progress(
      userId: userId ?? this.userId,
      languageId: languageId ?? this.languageId,
      currentUnitId: currentUnitId ?? this.currentUnitId,
      currentLessonId: currentLessonId ?? this.currentLessonId,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      skillStates: skillStates ?? this.skillStates,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'languageId': languageId,
        'currentUnitId': currentUnitId,
        'currentLessonId': currentLessonId,
        'xp': xp,
        'streak': streak,
        'skillStates': skillStates,
      };

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      userId: json['userId'] as String? ?? '',
      languageId: json['languageId'] as String? ?? '',
      currentUnitId: json['currentUnitId'] as String? ?? '',
      currentLessonId: json['currentLessonId'] as String? ?? '',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      skillStates: Map<String, int>.from(
        (json['skillStates'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v as num).toInt()),
            ) ??
            const {},
      ),
    );
  }
}

