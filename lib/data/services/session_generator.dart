import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lesson_session_model.dart';
import '../models/user_learning_profile.dart';
import 'srs_service.dart';
import 'content_loader.dart';
import 'progression_policy_service.dart';

final sessionGeneratorProvider = Provider<SessionGenerator>((ref) {
  final srsService = ref.watch(srsServiceProvider);
  final contentLoader = ref.watch(contentLoaderProvider);
  final policy = ref.watch(progressionPolicyProvider);
  return SessionGenerator(srsService, contentLoader, policy);
});

/// Generates interactive sessions from static content.
/// Mixes new content, review items, and weak items intelligently.
class SessionGenerator {
  SessionGenerator(this._srsService, this._contentLoader, this._policy);

  final SrsService _srsService;
  final ContentLoader _contentLoader;
  final ProgressionPolicyService _policy;
  final _random = Random();

  /// Generate a lesson session for a specific lesson.
  Future<LessonSession> generateLessonSession({
    required String languageId,
    required String lessonId,
    required int difficulty,
    UserLearningProfile? profile,
  }) async {
    final vocab = await _contentLoader.loadVocabulary(languageId);
    final allWords = vocab.expand((cat) => cat.words).toList();

    // Get items from the lesson's scope (based on lesson ID pattern).
    final lessonWords = _getLessonWords(lessonId, allWords);
    final dueCards = _srsService.getDueCards(languageId);
    final weakCards = _srsService.getWeakItems(languageId, count: 5);

    // Build item mix.
    final exerciseItems = <ContentWord>[];

    // 40% new content from current lesson.
    final newCount = (6 * 0.4).ceil();
    exerciseItems.addAll(_takeRandom(lessonWords, newCount));

    // 30% due review items (SRS).
    final reviewCount = (6 * 0.3).ceil();
    final reviewWordIds = dueCards.take(reviewCount).map((c) => c.itemId).toSet();
    exerciseItems.addAll(
      allWords.where((w) => reviewWordIds.contains(w.id)).take(reviewCount),
    );

    // 30% weak items for reinforcement.
    final weakCount = 6 - exerciseItems.length;
    final weakWordIds = weakCards.take(weakCount).map((c) => c.itemId).toSet();
    exerciseItems.addAll(
      allWords.where((w) => weakWordIds.contains(w.id)).take(weakCount),
    );

    // Fill remaining with lesson words if not enough.
    while (exerciseItems.length < 5) {
      final remaining = allWords.where((w) =>
          !exerciseItems.any((e) => e.id == w.id)).toList();
      if (remaining.isEmpty) break;
      exerciseItems.add(remaining[_random.nextInt(remaining.length)]);
    }

    // Generate exercises from items.
    final exercises = <SessionExercise>[];
    for (int i = 0; i < exerciseItems.length; i++) {
      final item = exerciseItems[i];
      final type = _pickExerciseType(difficulty, profile);
      exercises.add(_createExercise(
        item: item,
        type: type,
        allWords: allWords,
        index: i,
        difficulty: difficulty,
      ));
    }

    // Sort: easier exercises first.
    exercises.sort((a, b) {
      const order = {
        ExerciseType.mcq: 0,
        ExerciseType.match: 1,
        ExerciseType.fillBlank: 2,
        ExerciseType.translate: 3,
        ExerciseType.sentenceBuild: 4,
        ExerciseType.listening: 5,
      };
      return (order[a.type] ?? 0).compareTo(order[b.type] ?? 0);
    });

    final xpReward = _calculateXpReward(difficulty, exercises.length);

    return LessonSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: lessonId,
      languageId: languageId,
      exercises: exercises,
      difficulty: difficulty,
      xpReward: xpReward,
      targetDuration: const Duration(minutes: 3),
      sessionType: SessionType.lesson,
    );
  }

  /// Generate a warm-up review session from SRS due items.
  Future<LessonSession> generateWarmupSession({
    required String languageId,
  }) async {
    final dueCards = _srsService.getReviewQueue(languageId, limit: 6);
    final vocab = await _contentLoader.loadVocabulary(languageId);
    final allWords = vocab.expand((cat) => cat.words).toList();

    final exercises = <SessionExercise>[];
    for (int i = 0; i < dueCards.length; i++) {
      final card = dueCards[i];
      final word = allWords.where((w) => w.id == card.itemId).firstOrNull;
      if (word == null) continue;

      exercises.add(_createExercise(
        item: word,
        type: ExerciseType.mcq,
        allWords: allWords,
        index: i,
        difficulty: 3,
      ));
    }

    return LessonSession(
      id: 'warmup_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: 'warmup',
      languageId: languageId,
      exercises: exercises,
      difficulty: 3,
      xpReward: exercises.length * 2,
      targetDuration: const Duration(minutes: 2),
      sessionType: SessionType.warmup,
    );
  }

  /// Generate a practice session mixing weak and recent items.
  Future<LessonSession> generatePracticeSession({
    required String languageId,
    required int difficulty,
    UserLearningProfile? profile,
  }) async {
    final weakCards = _srsService.getWeakItems(languageId, count: 8);
    final dueCards = _srsService.getDueCards(languageId);
    final vocab = await _contentLoader.loadVocabulary(languageId);
    final allWords = vocab.expand((cat) => cat.words).toList();
    final severeWeakQueue = weakCards.length >= 4;
    final mix = _policy.practiceSessionMix(severeWeakQueue: severeWeakQueue);

    final exercises = <SessionExercise>[];

    // Repair block share.
    final weakWordIds = weakCards.map((c) => c.itemId).toSet();
    final weakWords = allWords.where((w) => weakWordIds.contains(w.id)).toList();
    final repairWords = _takeRandom(weakWords, mix.repairItems);
    for (int i = 0; i < repairWords.length; i++) {
      final type = _pickExerciseType((difficulty - 1).clamp(1, 10), profile);
      exercises.add(_createExercise(
        item: repairWords[i],
        type: type,
        allWords: allWords,
        index: exercises.length,
        difficulty: (difficulty - 1).clamp(1, 10),
      ));
    }

    // Review share.
    final dueWordIds = dueCards.map((c) => c.itemId).toSet();
    final dueWords = allWords.where((w) => dueWordIds.contains(w.id)).toList();
    final reviewWords = _takeRandom(
      dueWords.where((w) => !repairWords.any((r) => r.id == w.id)).toList(),
      mix.reviewItems,
    );
    for (int i = 0; i < reviewWords.length; i++) {
      final type = _pickExerciseType(difficulty, profile);
      exercises.add(_createExercise(
        item: reviewWords[i],
        type: type,
        allWords: allWords,
        index: exercises.length,
        difficulty: difficulty,
      ));
    }

    // New share.
    final usedIds = exercises.map((e) => e.relatedItemId).whereType<String>().toSet();
    final newPool = allWords.where((w) => !usedIds.contains(w.id)).toList();
    final newWords = _takeRandom(newPool, mix.newItems);
    for (int i = 0; i < newWords.length; i++) {
      final type = _pickExerciseType(difficulty + 1, profile);
      exercises.add(_createExercise(
        item: newWords[i],
        type: type,
        allWords: allWords,
        index: exercises.length,
        difficulty: (difficulty + 1).clamp(1, 10),
      ));
    }

    // Top up to full 15-item session.
    while (exercises.length < mix.total && allWords.isNotEmpty) {
      final word = allWords[_random.nextInt(allWords.length)];
      exercises.add(_createExercise(
        item: word,
        type: _pickExerciseType(difficulty, profile),
        allWords: allWords,
        index: exercises.length,
        difficulty: difficulty,
      ));
    }

    // Keep exactly target total.
    if (exercises.length > mix.total) {
      exercises.removeRange(mix.total, exercises.length);
    }

    return LessonSession(
      id: 'practice_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: 'practice',
      languageId: languageId,
      exercises: exercises,
      difficulty: difficulty,
      xpReward: exercises.length * 3,
      targetDuration: const Duration(minutes: 6),
      sessionType: SessionType.practice,
    );
  }

  /// Generate a challenge session (harder difficulty).
  Future<LessonSession> generateChallengeSession({
    required String languageId,
    required int difficulty,
  }) async {
    final vocab = await _contentLoader.loadVocabulary(languageId);
    final allWords = vocab.expand((cat) => cat.words).toList();

    final challengeWords = _takeRandom(allWords, 6);
    final exercises = <SessionExercise>[];

    for (int i = 0; i < challengeWords.length; i++) {
      // Challenge uses harder exercise types.
      final types = [
        ExerciseType.fillBlank,
        ExerciseType.translate,
        ExerciseType.sentenceBuild,
      ];
      final type = types[_random.nextInt(types.length)];
      exercises.add(_createExercise(
        item: challengeWords[i],
        type: type,
        allWords: allWords,
        index: i,
        difficulty: difficulty + 2,
      ));
    }

    return LessonSession(
      id: 'challenge_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: 'challenge',
      languageId: languageId,
      exercises: exercises,
      difficulty: (difficulty + 2).clamp(1, 10),
      xpReward: exercises.length * 5,
      targetDuration: const Duration(minutes: 2),
      sessionType: SessionType.challenge,
    );
  }

  // ─── Private Helpers ─────────────────────────────────────────────

  SessionExercise _createExercise({
    required ContentWord item,
    required ExerciseType type,
    required List<ContentWord> allWords,
    required int index,
    required int difficulty,
  }) {
    switch (type) {
      case ExerciseType.mcq:
        return _createMcqExercise(item, allWords, index);
      case ExerciseType.fillBlank:
        return _createFillBlankExercise(item, index);
      case ExerciseType.translate:
        return _createTranslateExercise(item, index);
      case ExerciseType.sentenceBuild:
        return _createSentenceBuildExercise(item, index);
      case ExerciseType.match:
        return _createMcqExercise(item, allWords, index); // fallback to MCQ
      case ExerciseType.listening:
        return _createMcqExercise(item, allWords, index);
    }
  }

  SessionExercise _createMcqExercise(
    ContentWord item,
    List<ContentWord> allWords,
    int index,
  ) {
    // Generate 3 distractors from same category.
    final sameCategory = allWords
        .where((w) => w.category == item.category && w.id != item.id)
        .toList();
    final distractors = _takeRandom(
      sameCategory.isNotEmpty ? sameCategory : allWords.where((w) => w.id != item.id).toList(),
      3,
    );

    final options = [
      item.english,
      ...distractors.map((d) => d.english),
    ]..shuffle(_random);

    return SessionExercise(
      id: 'ex_mcq_${index}_${item.id}',
      type: ExerciseType.mcq,
      question: 'What does "${item.target}" mean?',
      questionTransliteration: item.transliteration,
      options: options,
      correctAnswer: item.english,
      explanation:
          '${item.target} (${item.transliteration}) = ${item.english}',
      points: 5,
      relatedItemId: item.id,
    );
  }

  SessionExercise _createFillBlankExercise(ContentWord item, int index) {
    final sentence = item.exampleTarget ?? '${item.target} ...';
    final blanked = sentence.replaceAll(item.target, '___');

    return SessionExercise(
      id: 'ex_fill_${index}_${item.id}',
      type: ExerciseType.fillBlank,
      question: 'Fill in the blank:\n$blanked',
      correctAnswer: item.target,
      hint: item.transliteration,
      explanation:
          'The correct word is "${item.target}" (${item.english})',
      points: 7,
      relatedItemId: item.id,
    );
  }

  SessionExercise _createTranslateExercise(ContentWord item, int index) {
    return SessionExercise(
      id: 'ex_trans_${index}_${item.id}',
      type: ExerciseType.translate,
      question: 'Translate to the target language:\n"${item.english}"',
      correctAnswer: item.target,
      hint: item.transliteration,
      explanation:
          '${item.english} = ${item.target} (${item.transliteration})',
      points: 10,
      relatedItemId: item.id,
    );
  }

  SessionExercise _createSentenceBuildExercise(ContentWord item, int index) {
    final sentence = item.exampleTarget ?? item.target;
    final words = sentence.split(' ')..shuffle(_random);

    return SessionExercise(
      id: 'ex_build_${index}_${item.id}',
      type: ExerciseType.sentenceBuild,
      question: 'Arrange the words:\n"${item.exampleEnglish ?? item.english}"',
      correctAnswer: sentence,
      wordBank: words,
      explanation: 'Correct: $sentence',
      points: 10,
      relatedItemId: item.id,
    );
  }

  ExerciseType _pickExerciseType(
    int difficulty,
    UserLearningProfile? profile,
  ) {
    // Weight exercise types based on difficulty and user weakness.
    if (difficulty <= 3) {
      // Easy: mostly MCQ.
      const types = [
        ExerciseType.mcq,
        ExerciseType.mcq,
        ExerciseType.mcq,
        ExerciseType.fillBlank,
      ];
      return types[_random.nextInt(types.length)];
    } else if (difficulty <= 6) {
      const types = [
        ExerciseType.mcq,
        ExerciseType.fillBlank,
        ExerciseType.translate,
        ExerciseType.match,
      ];
      return types[_random.nextInt(types.length)];
    } else {
      const types = [
        ExerciseType.fillBlank,
        ExerciseType.translate,
        ExerciseType.sentenceBuild,
        ExerciseType.translate,
      ];
      return types[_random.nextInt(types.length)];
    }
  }

  List<ContentWord> _getLessonWords(
    String lessonId,
    List<ContentWord> allWords,
  ) {
    // Match lesson ID to category. E.g., "greetings_a1" → "Greetings".
    final parts = lessonId.split('_');
    if (parts.isEmpty) return allWords.take(10).toList();

    final category = parts.first;
    final matches = allWords
        .where((w) => w.category.toLowerCase().contains(category))
        .toList();
    return matches.isNotEmpty ? matches : allWords.take(10).toList();
  }

  List<T> _takeRandom<T>(List<T> items, int count) {
    if (items.isEmpty) return [];
    final shuffled = List<T>.from(items)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  int _calculateXpReward(int difficulty, int exerciseCount) {
    return (exerciseCount * 3 + difficulty * 2).clamp(10, 50);
  }
}
