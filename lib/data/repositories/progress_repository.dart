import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../models/user_progress_model.dart';
import 'auth_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return ProgressRepository(firestore, auth);
});

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgressModel>((ref) {
  final repo = ref.watch(progressRepositoryProvider);
  final notifier = UserProgressNotifier(repo);
  ref.listen<AuthState>(authStateProvider, (_, next) {
    notifier.handleAuthStateChanged(next);
  });
  return notifier;
});

class ProgressRepository {
  ProgressRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get currentUserId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Future<UserProgressModel> loadProgress() async {
    final uid = currentUserId;
    if (uid == null) return UserProgressModel.initial();

    final snapshot = await _userDoc(uid).get();
    final data = snapshot.data();
    final progress = data?['progress'] as Map<String, dynamic>?;
    if (progress == null) {
      final initial = UserProgressModel.initial();
      await saveProgress(initial);
      return initial;
    }

    final lastLoginStr = progress['lastLoginDate'] as String?;
    final lastLogin =
        lastLoginStr != null ? DateTime.parse(lastLoginStr) : DateTime.now();
    final categoryProgress =
        Map<String, int>.from((progress['categoryProgress'] as Map?) ?? {});
    final completedLessons = Set<String>.from(
      (progress['completedLessons'] as List?) ?? const [],
    );
    final practicedItems = Set<String>.from(
      (progress['practicedItems'] as List?) ?? const [],
    );

    final model = UserProgressModel(
      xpPoints: (progress['xpPoints'] as num?)?.toInt() ?? 0,
      streakDays: (progress['streakDays'] as num?)?.toInt() ?? 1,
      wordsLearned: (progress['wordsLearned'] as num?)?.toInt() ?? 0,
      lessonsCompleted: (progress['lessonsCompleted'] as num?)?.toInt() ?? 0,
      currentLevel: progress['currentLevel'] as String? ?? 'A1',
      lastLoginDate: lastLogin,
      categoryProgress: categoryProgress,
      dailyGoal: (progress['dailyGoal'] as num?)?.toInt() ?? 50,
      todayXp: (progress['todayXp'] as num?)?.toInt() ?? 0,
      completedLessons: completedLessons,
      practicedItems: practicedItems,
    );

    final today = DateTime.now();
    final isToday = lastLogin.year == today.year &&
        lastLogin.month == today.month &&
        lastLogin.day == today.day;

    if (isToday) return model;
    return model.copyWith(todayXp: 0);
  }

  Future<void> saveProgress(UserProgressModel progress) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _userDoc(uid).set({
      'updatedAt': FieldValue.serverTimestamp(),
      'progress': {
        'xpPoints': progress.xpPoints,
        'streakDays': progress.streakDays,
        'wordsLearned': progress.wordsLearned,
        'lessonsCompleted': progress.lessonsCompleted,
        'currentLevel': progress.currentLevel,
        'lastLoginDate': progress.lastLoginDate.toIso8601String(),
        'categoryProgress': progress.categoryProgress,
        'dailyGoal': progress.dailyGoal,
        'todayXp': progress.todayXp,
        'completedLessons': progress.completedLessons.toList(),
        'practicedItems': progress.practicedItems.toList(),
      },
    }, SetOptions(merge: true));
  }

  Future<bool> markWordLearned(String wordId) async {
    final uid = currentUserId;
    if (uid == null) return false;

    final snapshot = await _userDoc(uid).get();
    final data = snapshot.data();
    final learnedWords = List<String>.from(
      data?['learnedWords'] as List? ?? const [],
    );
    if (learnedWords.contains(wordId)) {
      return false;
    }

    learnedWords.add(wordId);
    await _userDoc(uid).set({
      'updatedAt': FieldValue.serverTimestamp(),
      'learnedWords': learnedWords,
    }, SetOptions(merge: true));
    return true;
  }

  Future<List<String>> getLearnedWordIds() async {
    final uid = currentUserId;
    if (uid == null) return const [];
    final snapshot = await _userDoc(uid).get();
    final data = snapshot.data();
    return List<String>.from(data?['learnedWords'] as List? ?? const []);
  }
}

class UserProgressNotifier extends StateNotifier<UserProgressModel> {
  UserProgressNotifier(this._repo) : super(UserProgressModel.initial()) {
    _load();
  }

  final ProgressRepository _repo;
  bool _isLoading = false;

  Future<void> handleAuthStateChanged(AuthState authState) async {
    if (authState.status != AuthStatus.authenticated) {
      state = UserProgressModel.initial();
      return;
    }
    await _load();
  }

  Future<void> _load() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final loaded = await _repo.loadProgress();
      state = loaded;
      await _checkAndUpdateStreak();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _checkAndUpdateStreak() async {
    final today = DateTime.now();
    final last = state.lastLoginDate;
    final daysDiff = today.difference(
      DateTime(last.year, last.month, last.day),
    ).inDays;

    if (daysDiff == 1) {
      final newXp = state.xpPoints + AppConstants.xpForStreak;
      final updated = state.copyWith(
        streakDays: state.streakDays + 1,
        lastLoginDate: today,
        xpPoints: newXp,
        todayXp: state.todayXp + AppConstants.xpForStreak,
        currentLevel: _computeLevel(newXp),
      );
      state = updated;
      await _repo.saveProgress(updated);
    } else if (daysDiff > 1) {
      final updated = state.copyWith(
        streakDays: 1,
        lastLoginDate: today,
        todayXp: 0,
      );
      state = updated;
      await _repo.saveProgress(updated);
    }
  }

  Future<void> addXp(int amount) async {
    final newXp = state.xpPoints + amount;
    final updated = state.copyWith(
      xpPoints: newXp,
      todayXp: state.todayXp + amount,
      currentLevel: _computeLevel(newXp),
    );
    state = updated;
    await _repo.saveProgress(updated);
  }

  Future<bool> addQuizXp(
    String lessonId,
    int score,
    int total, {
    int baseXp = 15,
  }) async {
    if (state.completedLessons.contains(lessonId)) {
      return false;
    }

    final earnedXp =
        total > 0 ? ((baseXp * score) / total).round().clamp(1, baseXp) : 0;
    if (earnedXp <= 0) return false;

    final newCompletedLessons = Set<String>.from(state.completedLessons)
      ..add(lessonId);
    final newXp = state.xpPoints + earnedXp;
    final updated = state.copyWith(
      xpPoints: newXp,
      todayXp: state.todayXp + earnedXp,
      currentLevel: _computeLevel(newXp),
      completedLessons: newCompletedLessons,
      lessonsCompleted: state.lessonsCompleted + 1,
    );
    state = updated;
    await _repo.saveProgress(updated);
    return true;
  }

  Future<void> markLessonComplete(String lessonId) async {
    if (state.completedLessons.contains(lessonId)) return;
    final updated = state.copyWith(
      completedLessons: {...state.completedLessons, lessonId},
      lessonsCompleted: state.lessonsCompleted + 1,
    );
    state = updated;
    await _repo.saveProgress(updated);
  }

  Future<void> markItemPracticed(String itemId) async {
    if (state.practicedItems.contains(itemId)) return;
    final updated = state.copyWith(
      practicedItems: {...state.practicedItems, itemId},
    );
    state = updated;
    await _repo.saveProgress(updated);
    await addXp(2);
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

  Future<bool> markNewWordLearned(String wordId, {String? category}) async {
    final isNewWord = await _repo.markWordLearned(wordId);
    if (!isNewWord) return false;

    await incrementWords(1);

    if (category != null) {
      final currentCount = state.categoryProgress[category] ?? 0;
      await updateCategoryProgress(category, currentCount + 1);
    }
    return true;
  }

  Future<void> updateCategoryProgress(String category, int learnedCount) async {
    final updated = state.copyWith(
      categoryProgress: {
        ...state.categoryProgress,
        category: learnedCount,
      },
    );
    state = updated;
    await _repo.saveProgress(updated);
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
