class UserProgressModel {
  final int xpPoints;
  final int streakDays;
  final int wordsLearned;
  final int lessonsCompleted;
  final String currentLevel;
  final DateTime lastLoginDate;
  final Map<String, int> categoryProgress;
  final int dailyGoal;
  final int todayXp;

  const UserProgressModel({
    required this.xpPoints,
    required this.streakDays,
    required this.wordsLearned,
    required this.lessonsCompleted,
    required this.currentLevel,
    required this.lastLoginDate,
    required this.categoryProgress,
    required this.dailyGoal,
    required this.todayXp,
  });

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

  UserProgressModel copyWith({
    int? xpPoints,
    int? streakDays,
    int? wordsLearned,
    int? lessonsCompleted,
    String? currentLevel,
    DateTime? lastLoginDate,
    Map<String, int>? categoryProgress,
    int? dailyGoal,
    int? todayXp,
  }) {
    return UserProgressModel(
      xpPoints: xpPoints ?? this.xpPoints,
      streakDays: streakDays ?? this.streakDays,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      currentLevel: currentLevel ?? this.currentLevel,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      todayXp: todayXp ?? this.todayXp,
    );
  }
}
