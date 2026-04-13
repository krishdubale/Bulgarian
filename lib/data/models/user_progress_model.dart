class UserProgressModel {
  final String languageId;
  final int xpPoints;
  final int streakDays;
  final int wordsLearned;
  final int lessonsCompleted;
  final String currentLevel;
  final DateTime lastLoginDate;
  final Map<String, int> categoryProgress;
  final int dailyGoal;
  final int todayXp;
  final Set<String> completedLessons;
  final Set<String> practicedItems;
  final int currentLessonIndex; // index into the lesson sequence
  final int streakFreezeCount;
  final int longestStreak;
  final Set<String> awardedMilestones;

  const UserProgressModel({
    this.languageId = 'bg',
    required this.xpPoints,
    required this.streakDays,
    required this.wordsLearned,
    required this.lessonsCompleted,
    required this.currentLevel,
    required this.lastLoginDate,
    required this.categoryProgress,
    required this.dailyGoal,
    required this.todayXp,
    this.completedLessons = const {},
    this.practicedItems = const {},
    this.currentLessonIndex = 0,
    this.streakFreezeCount = 3,
    this.longestStreak = 0,
    this.awardedMilestones = const {},
  });

  factory UserProgressModel.initial({String languageId = 'bg'}) {
    return UserProgressModel(
      languageId: languageId,
      xpPoints: 0,
      streakDays: 1,
      wordsLearned: 0,
      lessonsCompleted: 0,
      currentLevel: 'A1',
      lastLoginDate: DateTime.now(),
      categoryProgress: const {},
      dailyGoal: 50,
      todayXp: 0,
    );
  }

  String get levelDisplayName {
    const descriptions = {
      'A1': 'A1 - Beginner',
      'A2': 'A2 - Elementary',
      'B1': 'B1 - Intermediate',
      'B2': 'B2 - Upper Intermediate',
      'C1': 'C1 - Advanced',
      'C2': 'C2 - Mastery',
    };
    return descriptions[currentLevel] ?? 'A1 - Beginner';
  }

  double get dailyGoalProgress =>
      dailyGoal > 0 ? (todayXp / dailyGoal).clamp(0.0, 1.0) : 0.0;

  /// Check if a specific lesson/quiz has been completed
  bool isLessonCompleted(String lessonId) => completedLessons.contains(lessonId);

  /// Check if a specific item (letter, phrase) has been practiced
  bool isItemPracticed(String itemId) => practicedItems.contains(itemId);

  UserProgressModel copyWith({
    String? languageId,
    int? xpPoints,
    int? streakDays,
    int? wordsLearned,
    int? lessonsCompleted,
    String? currentLevel,
    DateTime? lastLoginDate,
    Map<String, int>? categoryProgress,
    int? dailyGoal,
    int? todayXp,
    Set<String>? completedLessons,
    Set<String>? practicedItems,
    int? currentLessonIndex,
    int? streakFreezeCount,
    int? longestStreak,
    Set<String>? awardedMilestones,
  }) {
    return UserProgressModel(
      languageId: languageId ?? this.languageId,
      xpPoints: xpPoints ?? this.xpPoints,
      streakDays: streakDays ?? this.streakDays,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      currentLevel: currentLevel ?? this.currentLevel,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      todayXp: todayXp ?? this.todayXp,
      completedLessons: completedLessons ?? this.completedLessons,
      practicedItems: practicedItems ?? this.practicedItems,
      currentLessonIndex: currentLessonIndex ?? this.currentLessonIndex,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
      longestStreak: longestStreak ?? this.longestStreak,
      awardedMilestones: awardedMilestones ?? this.awardedMilestones,
    );
  }
}
