import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProgressRepository(prefs);
});

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgressModel>((ref) {
  final repo = ref.watch(progressRepositoryProvider);
  return UserProgressNotifier(repo);
});

class ProgressRepository {
  final SharedPreferences _prefs;

  ProgressRepository(this._prefs);

  UserProgressModel loadProgress() {
    final xp = _prefs.getInt(AppConstants.keyXpPoints) ?? 0;
    final streak = _prefs.getInt(AppConstants.keyStreakDays) ?? 0;
    final words = _prefs.getInt(AppConstants.keyWordsLearned) ?? 0;
    final lessons = _prefs.getInt(AppConstants.keyLessonsCompleted) ?? 0;
    final level = _prefs.getString(AppConstants.keyCurrentLevel) ?? 'A1';
    final dailyGoal = _prefs.getInt(AppConstants.keyDailyGoal) ?? 50;
    final lastLoginStr = _prefs.getString(AppConstants.keyLastLoginDate);
    final lastLogin = lastLoginStr != null
        ? DateTime.parse(lastLoginStr)
        : DateTime.now();

    final categoryJson = _prefs.getString('category_progress');
    Map<String, int> categoryProgress = {};
    if (categoryJson != null) {
      final decoded = jsonDecode(categoryJson) as Map<String, dynamic>;
      categoryProgress = decoded.map((k, v) => MapEntry(k, v as int));
    }

    final today = DateTime.now();
    final isToday = lastLogin.year == today.year &&
        lastLogin.month == today.month &&
        lastLogin.day == today.day;
    final todayXp = isToday ? (_prefs.getInt('today_xp') ?? 0) : 0;

    return UserProgressModel(
      xpPoints: xp,
      streakDays: streak,
      wordsLearned: words,
      lessonsCompleted: lessons,
      currentLevel: level,
      lastLoginDate: lastLogin,
      categoryProgress: categoryProgress,
      dailyGoal: dailyGoal,
      todayXp: todayXp,
    );
  }

  Future<void> saveProgress(UserProgressModel progress) async {
    await _prefs.setInt(AppConstants.keyXpPoints, progress.xpPoints);
    await _prefs.setInt(AppConstants.keyStreakDays, progress.streakDays);
    await _prefs.setInt(AppConstants.keyWordsLearned, progress.wordsLearned);
    await _prefs.setInt(
        AppConstants.keyLessonsCompleted, progress.lessonsCompleted);
    await _prefs.setString(AppConstants.keyCurrentLevel, progress.currentLevel);
    await _prefs.setInt(AppConstants.keyDailyGoal, progress.dailyGoal);
    await _prefs.setString(
        AppConstants.keyLastLoginDate, progress.lastLoginDate.toIso8601String());
    await _prefs.setInt('today_xp', progress.todayXp);
    await _prefs.setString(
        'category_progress', jsonEncode(progress.categoryProgress));
  }

  Future<void> markWordLearned(String wordId) async {
    final learned =
        _prefs.getStringList(AppConstants.keyLearnedWords) ?? [];
    if (!learned.contains(wordId)) {
      learned.add(wordId);
      await _prefs.setStringList(AppConstants.keyLearnedWords, learned);
    }
  }

  List<String> getLearnedWordIds() {
    return _prefs.getStringList(AppConstants.keyLearnedWords) ?? [];
  }
}

class UserProgressNotifier extends StateNotifier<UserProgressModel> {
  final ProgressRepository _repo;

  UserProgressNotifier(this._repo) : super(_repo.loadProgress()) {
    _checkAndUpdateStreak();
  }

  void _checkAndUpdateStreak() {
    final today = DateTime.now();
    final last = state.lastLoginDate;
    final daysDiff = today.difference(
      DateTime(last.year, last.month, last.day),
    ).inDays;

    if (daysDiff == 1) {
      // Consecutive day – increment streak
      final updated = state.copyWith(
        streakDays: state.streakDays + 1,
        lastLoginDate: today,
        xpPoints: state.xpPoints + AppConstants.xpForStreak,
        todayXp: state.todayXp + AppConstants.xpForStreak,
      );
      state = updated;
      _repo.saveProgress(updated);
    } else if (daysDiff > 1) {
      // Missed days – reset streak
      final updated = state.copyWith(
        streakDays: 1,
        lastLoginDate: today,
        todayXp: 0,
      );
      state = updated;
      _repo.saveProgress(updated);
    }
  }

  Future<void> addXp(int amount) async {
    final newXp = state.xpPoints + amount;
    final newTodayXp = state.todayXp + amount;
    final newLevel = _computeLevel(newXp);
    final updated = state.copyWith(
      xpPoints: newXp,
      todayXp: newTodayXp,
      currentLevel: newLevel,
    );
    state = updated;
    await _repo.saveProgress(updated);
  }

  Future<void> incrementLessons() async {
    final updated = state.copyWith(
      lessonsCompleted: state.lessonsCompleted + 1,
    );
    state = updated;
    await _repo.saveProgress(updated);
    await addXp(AppConstants.xpPerLesson);
  }

  Future<void> incrementWords(int count) async {
    final updated = state.copyWith(
      wordsLearned: state.wordsLearned + count,
    );
    state = updated;
    await _repo.saveProgress(updated);
    await addXp(count * AppConstants.xpPerWord);
  }

  Future<void> setDailyGoal(int goal) async {
    final updated = state.copyWith(dailyGoal: goal);
    state = updated;
    await _repo.saveProgress(updated);
  }

  String _computeLevel(int xp) {
    if (xp >= AppConstants.levelXpRequirements['C2']!) return 'C2';
    if (xp >= AppConstants.levelXpRequirements['C1']!) return 'C1';
    if (xp >= AppConstants.levelXpRequirements['B2']!) return 'B2';
    if (xp >= AppConstants.levelXpRequirements['B1']!) return 'B1';
    if (xp >= AppConstants.levelXpRequirements['A2']!) return 'A2';
    return 'A1';
  }
}
