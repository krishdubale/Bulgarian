import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_progress_model.dart';
import '../models/srs_model.dart';


final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(FirebaseFirestore.instance);
});

/// Handles bidirectional data sync between local storage and Firestore.
class SyncService {
  SyncService(this._firestore);

  final FirebaseFirestore _firestore;

  /// Upload user progress for a specific language to Firestore.
  Future<void> uploadProgress({
    required String userId,
    required String languageId,
    required UserProgressModel progress,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('languages')
          .doc(languageId)
          .set({
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
        'currentLessonIndex': progress.currentLessonIndex,
        'streakFreezeCount': progress.streakFreezeCount,
        'longestStreak': progress.longestStreak,
        'awardedMilestones': progress.awardedMilestones.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail — local data is primary
    }
  }

  /// Download progress for a specific language from Firestore.
  Future<UserProgressModel?> downloadProgress({
    required String userId,
    required String languageId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('languages')
          .doc(languageId)
          .get();

      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;

      return UserProgressModel(
        languageId: languageId,
        xpPoints: (data['xpPoints'] as num?)?.toInt() ?? 0,
        streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
        wordsLearned: (data['wordsLearned'] as num?)?.toInt() ?? 0,
        lessonsCompleted: (data['lessonsCompleted'] as num?)?.toInt() ?? 0,
        currentLevel: data['currentLevel'] as String? ?? 'A1',
        lastLoginDate: data['lastLoginDate'] != null
            ? DateTime.parse(data['lastLoginDate'] as String)
            : DateTime.now(),
        categoryProgress:
            Map<String, int>.from(data['categoryProgress'] as Map? ?? {}),
        dailyGoal: (data['dailyGoal'] as num?)?.toInt() ?? 50,
        todayXp: (data['todayXp'] as num?)?.toInt() ?? 0,
        completedLessons:
            Set<String>.from(data['completedLessons'] as List? ?? []),
        practicedItems:
            Set<String>.from(data['practicedItems'] as List? ?? []),
        currentLessonIndex:
            (data['currentLessonIndex'] as num?)?.toInt() ?? 0,
        streakFreezeCount:
            (data['streakFreezeCount'] as num?)?.toInt() ?? 3,
        longestStreak: (data['longestStreak'] as num?)?.toInt() ?? 0,
        awardedMilestones:
            Set<String>.from(data['awardedMilestones'] as List? ?? []),
      );
    } catch (e) {
      return null;
    }
  }

  /// Upload SRS cards for a language.
  Future<void> uploadSrsCards({
    required String userId,
    required String languageId,
    required Map<String, SrsCard> cards,
  }) async {
    try {
      final batch = _firestore.batch();
      final baseRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('languages')
          .doc(languageId)
          .collection('srs_cards');

      for (final entry in cards.entries) {
        batch.set(baseRef.doc(entry.key), entry.value.toJson());
      }

      await batch.commit();
    } catch (e) {
      // Silently fail
    }
  }

  /// Download SRS cards for a language.
  Future<Map<String, SrsCard>> downloadSrsCards({
    required String userId,
    required String languageId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('languages')
          .doc(languageId)
          .collection('srs_cards')
          .get();

      final cards = <String, SrsCard>{};
      for (final doc in snapshot.docs) {
        cards[doc.id] = SrsCard.fromJson(doc.data());
      }
      return cards;
    } catch (e) {
      return {};
    }
  }

  /// Full sync — merge local and remote, keeping the most recent.
  Future<UserProgressModel> syncProgress({
    required String userId,
    required String languageId,
    required UserProgressModel localProgress,
  }) async {
    final remote = await downloadProgress(
      userId: userId,
      languageId: languageId,
    );

    if (remote == null) {
      // No remote data — upload local
      await uploadProgress(
        userId: userId,
        languageId: languageId,
        progress: localProgress,
      );
      return localProgress;
    }

    // Merge strategy: take the higher values
    final merged = localProgress.copyWith(
      xpPoints: localProgress.xpPoints > remote.xpPoints
          ? localProgress.xpPoints
          : remote.xpPoints,
      streakDays: localProgress.streakDays > remote.streakDays
          ? localProgress.streakDays
          : remote.streakDays,
      wordsLearned: localProgress.wordsLearned > remote.wordsLearned
          ? localProgress.wordsLearned
          : remote.wordsLearned,
      lessonsCompleted:
          localProgress.lessonsCompleted > remote.lessonsCompleted
              ? localProgress.lessonsCompleted
              : remote.lessonsCompleted,
      completedLessons:
          localProgress.completedLessons.union(remote.completedLessons),
      practicedItems:
          localProgress.practicedItems.union(remote.practicedItems),
      longestStreak: localProgress.longestStreak > remote.longestStreak
          ? localProgress.longestStreak
          : remote.longestStreak,
      awardedMilestones:
          localProgress.awardedMilestones.union(remote.awardedMilestones),
    );

    // Upload merged
    await uploadProgress(
      userId: userId,
      languageId: languageId,
      progress: merged,
    );

    return merged;
  }
}
