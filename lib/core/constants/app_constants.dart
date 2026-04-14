class AppConstants {
  AppConstants._();

  static const String appName = 'LinguaFlow';
  static const String appVersion = '1.0.0';

  static const List<String> levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  static const Map<String, String> levelDescriptions = {
    'A1': 'Beginner',
    'A2': 'Elementary',
    'B1': 'Intermediate',
    'B2': 'Upper Intermediate',
    'C1': 'Advanced',
    'C2': 'Mastery',
  };

  static const Map<String, int> levelXpRequirements = {
    'A1': 0,
    'A2': 500,
    'B1': 1500,
    'B2': 3000,
    'C1': 5500,
    'C2': 9000,
  };

  static const int xpPerLesson = 10;
  static const int xpPerWord = 5;
  static const int xpForStreak = 20;
  static const int xpForQuiz = 15;
  static const String initialLessonId = 'alphabet_a1';
  static const String initialUnitId = 'unit_1';
  static const List<String> defaultLessonSequence = [
    'alphabet_a1',
    'greetings_a1',
    'numbers_a1',
    'grammar_sentence_a1',
    'family_a1',
    'grammar_noun_gender_a1',
    'food_a1',
    'travel_a1',
    'colors_a1',
    'animals_a1',
  ];

  static const String keyXpPoints = 'xp_points';
  static const String keyStreakDays = 'streak_days';
  static const String keyWordsLearned = 'words_learned';
  static const String keyLessonsCompleted = 'lessons_completed';
  static const String keyCurrentLevel = 'current_level';
  static const String keyLastLoginDate = 'last_login_date';
  static const String keyDarkMode = 'dark_mode';
  static const String keyDailyGoal = 'daily_goal';
  static const String keyLearnedWords = 'learned_words';
  static const String keyCompletedLessons = 'completed_lessons';
  static const String keyPracticedItems = 'practiced_items';
  static const String keyWordMastery = 'word_mastery'; // JSON map: wordId -> {level, nextReview}
  static const String keyAuthEmail = 'auth_email';
  static const String keyAuthPasswordHash = 'auth_password_hash';
  static const String keyAuthDisplayName = 'auth_display_name';
  static const String keyIsLoggedIn = 'is_logged_in';

  /// Default vocabulary categories — loaded dynamically per language.
  static const List<String> defaultCategories = [
    'Greetings',
    'Numbers',
    'Family',
    'Food',
    'Travel',
    'Colors',
    'Animals',
    'Body',
    'Time',
  ];

  static const Map<String, String> categoryIcons = {
    'Greetings': '👋',
    'Numbers': '🔢',
    'Family': '👨‍👩‍👧‍👦',
    'Food': '🍎',
    'Travel': '✈️',
    'Colors': '🎨',
    'Animals': '🐾',
    'Body': '💪',
    'Time': '⏰',
  };
}
