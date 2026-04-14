import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/course_blueprint_model.dart';
import '../models/language_model.dart';

final contentLoaderProvider = Provider<ContentLoader>((ref) {
  return ContentLoader();
});

/// Vocabulary providers scoped by language.
final vocabularyProvider =
    FutureProvider.family<List<VocabularyCategory>, String>(
  (ref, languageId) async {
    final loader = ref.watch(contentLoaderProvider);
    return loader.loadVocabulary(languageId);
  },
);

final grammarProvider =
    FutureProvider.family<List<GrammarTopicData>, String>(
  (ref, languageId) async {
    final loader = ref.watch(contentLoaderProvider);
    return loader.loadGrammar(languageId);
  },
);

final lessonsProvider =
    FutureProvider.family<List<LessonDefinition>, String>(
  (ref, languageId) async {
    final loader = ref.watch(contentLoaderProvider);
    return loader.loadLessons(languageId);
  },
);

final alphabetProvider =
    FutureProvider.family<AlphabetData?, String>(
  (ref, languageId) async {
    final loader = ref.watch(contentLoaderProvider);
    return loader.loadAlphabet(languageId);
  },
);

final dialoguesProvider =
    FutureProvider.family<List<DialogueData>, String>(
  (ref, languageId) async {
    final loader = ref.watch(contentLoaderProvider);
    return loader.loadDialogues(languageId);
  },
);

final phrasesProvider =
    FutureProvider.family<List<PhraseData>, String>(
  (ref, languageId) async {
    final loader = ref.watch(contentLoaderProvider);
    return loader.loadPhrases(languageId);
  },
);

final readingProvider =
    FutureProvider.family<List<ReadingData>, String>(
  (ref, languageId) async {
    final loader = ref.watch(contentLoaderProvider);
    return loader.loadReading(languageId);
  },
);

final writingProvider =
    FutureProvider.family<List<WritingData>, String>(
  (ref, languageId) async {
    final loader = ref.watch(contentLoaderProvider);
    return loader.loadWriting(languageId);
  },
);

final courseBlueprintProvider = FutureProvider<CourseBlueprint>((ref) async {
  final loader = ref.watch(contentLoaderProvider);
  return loader.loadCourseBlueprint();
});

/// Dynamically loads content JSON for any language.
/// Caches loaded data in memory for performance.
class ContentLoader {
  final Map<String, List<VocabularyCategory>> _vocabCache = {};
  final Map<String, List<GrammarTopicData>> _grammarCache = {};
  final Map<String, List<LessonDefinition>> _lessonCache = {};
  final Map<String, AlphabetData?> _alphabetCache = {};
  final Map<String, List<DialogueData>> _dialogueCache = {};
  final Map<String, List<PhraseData>> _phraseCache = {};
  final Map<String, List<ReadingData>> _readingCache = {};
  final Map<String, List<WritingData>> _writingCache = {};
  CourseBlueprint? _courseBlueprintCache;

  /// Load vocabulary for a language.
  Future<List<VocabularyCategory>> loadVocabulary(String langId) async {
    if (_vocabCache.containsKey(langId)) return _vocabCache[langId]!;

    try {
      final raw = await rootBundle.loadString(
        'assets/data/languages/$langId/vocabulary.json',
      );
      final data = json.decode(raw) as Map<String, dynamic>;
      final categories = (data['categories'] as List)
          .map((c) => VocabularyCategory.fromJson(c as Map<String, dynamic>))
          .toList();
      _vocabCache[langId] = categories;
      return categories;
    } catch (e) {
      _vocabCache[langId] = [];
      return [];
    }
  }

  /// Load grammar topics for a language.
  Future<List<GrammarTopicData>> loadGrammar(String langId) async {
    if (_grammarCache.containsKey(langId)) return _grammarCache[langId]!;

    try {
      final raw = await rootBundle.loadString(
        'assets/data/languages/$langId/grammar.json',
      );
      final data = json.decode(raw) as Map<String, dynamic>;
      final topics = (data['topics'] as List)
          .map((t) => GrammarTopicData.fromJson(t as Map<String, dynamic>))
          .toList();
      _grammarCache[langId] = topics;
      return topics;
    } catch (e) {
      _grammarCache[langId] = [];
      return [];
    }
  }

  /// Load lesson definitions for a language.
  Future<List<LessonDefinition>> loadLessons(String langId) async {
    if (_lessonCache.containsKey(langId)) return _lessonCache[langId]!;

    try {
      final raw = await rootBundle.loadString(
        'assets/data/languages/$langId/lessons.json',
      );
      final data = json.decode(raw) as Map<String, dynamic>;
      final lessons = (data['lessons'] as List)
          .map((l) => LessonDefinition.fromJson(l as Map<String, dynamic>))
          .toList();
      _lessonCache[langId] = lessons;
      return lessons;
    } catch (e) {
      _lessonCache[langId] = [];
      return [];
    }
  }

  /// Load alphabet for a language (null for Latin-based languages).
  Future<AlphabetData?> loadAlphabet(String langId) async {
    if (_alphabetCache.containsKey(langId)) return _alphabetCache[langId];

    final lang = LanguageModel.getById(langId);
    if (!lang.hasAlphabet) {
      _alphabetCache[langId] = null;
      return null;
    }

    try {
      final raw = await rootBundle.loadString(
        'assets/data/languages/$langId/alphabet.json',
      );
      final data = json.decode(raw) as Map<String, dynamic>;
      final alphabet = AlphabetData.fromJson(data);
      _alphabetCache[langId] = alphabet;
      return alphabet;
    } catch (e) {
      _alphabetCache[langId] = null;
      return null;
    }
  }

  /// Load dialogues for a language.
  Future<List<DialogueData>> loadDialogues(String langId) async {
    if (_dialogueCache.containsKey(langId)) return _dialogueCache[langId]!;

    try {
      final raw = await rootBundle.loadString(
        'assets/data/languages/$langId/dialogues.json',
      );
      final data = json.decode(raw) as Map<String, dynamic>;
      final dialogues = (data['dialogues'] as List)
          .map((d) => DialogueData.fromJson(d as Map<String, dynamic>))
          .toList();
      _dialogueCache[langId] = dialogues;
      return dialogues;
    } catch (e) {
      _dialogueCache[langId] = [];
      return [];
    }
  }

  /// Load phrases for a language.
  Future<List<PhraseData>> loadPhrases(String langId) async {
    if (_phraseCache.containsKey(langId)) return _phraseCache[langId]!;

    try {
      final raw = await rootBundle.loadString(
        'assets/data/languages/$langId/phrases.json',
      );
      final data = json.decode(raw) as Map<String, dynamic>;
      final phrases = (data['phrases'] as List)
          .map((p) => PhraseData.fromJson(p as Map<String, dynamic>))
          .toList();
      _phraseCache[langId] = phrases;
      return phrases;
    } catch (e) {
      _phraseCache[langId] = [];
      return [];
    }
  }

  /// Load reading texts for a language.
  Future<List<ReadingData>> loadReading(String langId) async {
    if (_readingCache.containsKey(langId)) return _readingCache[langId]!;

    try {
      final raw = await rootBundle.loadString(
        'assets/data/languages/$langId/reading.json',
      );
      final data = json.decode(raw) as Map<String, dynamic>;
      final texts = (data['texts'] as List)
          .map((t) => ReadingData.fromJson(t as Map<String, dynamic>))
          .toList();
      _readingCache[langId] = texts;
      return texts;
    } catch (e) {
      _readingCache[langId] = [];
      return [];
    }
  }

  /// Load writing exercises for a language.
  Future<List<WritingData>> loadWriting(String langId) async {
    if (_writingCache.containsKey(langId)) return _writingCache[langId]!;

    try {
      final raw = await rootBundle.loadString(
        'assets/data/languages/$langId/writing.json',
      );
      final data = json.decode(raw) as Map<String, dynamic>;
      final exercises = (data['exercises'] as List)
          .map((e) => WritingData.fromJson(e as Map<String, dynamic>))
          .toList();
      _writingCache[langId] = exercises;
      return exercises;
    } catch (e) {
      _writingCache[langId] = [];
      return [];
    }
  }

  CourseBlueprint _emptyCourseBlueprint() {
    return CourseBlueprint.fromJson(const <String, dynamic>{});
  }

  /// Load the shared A1-B1 course blueprint.
  Future<CourseBlueprint> loadCourseBlueprint() async {
    if (_courseBlueprintCache != null) return _courseBlueprintCache!;

    try {
      final raw = await rootBundle.loadString(
        'assets/data/course_blueprint.json',
      );
      final data = json.decode(raw) as Map<String, dynamic>;
      _courseBlueprintCache = CourseBlueprint.fromJson(data);
      return _courseBlueprintCache!;
    } catch (e) {
      _courseBlueprintCache = _emptyCourseBlueprint();
      return _courseBlueprintCache!;
    }
  }

  /// Clear all cached data.
  void clearCache() {
    _vocabCache.clear();
    _grammarCache.clear();
    _lessonCache.clear();
    _alphabetCache.clear();
    _dialogueCache.clear();
    _phraseCache.clear();
    _readingCache.clear();
    _writingCache.clear();
    _courseBlueprintCache = null;
  }

  /// Preload all content for a language.
  Future<void> preloadLanguage(String langId) async {
    await Future.wait([
      loadVocabulary(langId),
      loadGrammar(langId),
      loadLessons(langId),
      loadAlphabet(langId),
      loadDialogues(langId),
      loadPhrases(langId),
      loadReading(langId),
      loadWriting(langId),
      loadCourseBlueprint(),
    ]);
  }
}

// ─── Content Data Models ───────────────────────────────────────────

/// A vocabulary word in any language.
class ContentWord {
  final String id;
  final String target; // the word in target language
  final String transliteration;
  final String english;
  final String category;
  final String level;
  final String? exampleTarget;
  final String? exampleEnglish;
  final String? audioFile;

  const ContentWord({
    required this.id,
    required this.target,
    required this.transliteration,
    required this.english,
    required this.category,
    this.level = 'A1',
    this.exampleTarget,
    this.exampleEnglish,
    this.audioFile,
  });

  factory ContentWord.fromJson(Map<String, dynamic> json) {
    return ContentWord(
      id: json['id'] as String? ?? '',
      target: json['target'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      english: json['english'] as String? ?? '',
      category: json['category'] as String? ?? '',
      level: json['level'] as String? ?? 'A1',
      exampleTarget: (json['example'] as Map?)?['target'] as String?,
      exampleEnglish: (json['example'] as Map?)?['english'] as String?,
      audioFile: json['audioFile'] as String?,
    );
  }
}

/// A category of vocabulary words.
class VocabularyCategory {
  final String id;
  final String name;
  final String icon;
  final List<ContentWord> words;

  const VocabularyCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.words,
  });

  factory VocabularyCategory.fromJson(Map<String, dynamic> json) {
    return VocabularyCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '📚',
      words: (json['words'] as List?)
              ?.map((w) => ContentWord.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// A grammar topic.
class GrammarTopicData {
  final String id;
  final String title;
  final String explanation;
  final String level;
  final List<GrammarExampleData> examples;
  final List<QuizQuestionData> quiz;

  const GrammarTopicData({
    required this.id,
    required this.title,
    required this.explanation,
    required this.level,
    required this.examples,
    required this.quiz,
  });

  factory GrammarTopicData.fromJson(Map<String, dynamic> json) {
    return GrammarTopicData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      level: json['level'] as String? ?? 'A1',
      examples: (json['examples'] as List?)
              ?.map((e) =>
                  GrammarExampleData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      quiz: (json['quiz'] as List?)
              ?.map(
                  (q) => QuizQuestionData.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class GrammarExampleData {
  final String target;
  final String transliteration;
  final String english;

  const GrammarExampleData({
    required this.target,
    required this.transliteration,
    required this.english,
  });

  factory GrammarExampleData.fromJson(Map<String, dynamic> json) {
    return GrammarExampleData(
      target: json['target'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      english: json['english'] as String? ?? '',
    );
  }
}

class QuizQuestionData {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const QuizQuestionData({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  factory QuizQuestionData.fromJson(Map<String, dynamic> json) {
    return QuizQuestionData(
      question: json['question'] as String? ?? '',
      options: List<String>.from(json['options'] as List? ?? []),
      correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String?,
    );
  }
}

/// Lesson definition.
class LessonDefinition {
  final String id;
  final String title;
  final String description;
  final String level;
  final String category;
  final int xpReward;
  final List<String> wordIds;
  final List<String> objectives;

  const LessonDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.category,
    this.xpReward = 15,
    this.wordIds = const [],
    this.objectives = const [],
  });

  factory LessonDefinition.fromJson(Map<String, dynamic> json) {
    return LessonDefinition(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: json['level'] as String? ?? 'A1',
      category: json['category'] as String? ?? '',
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 15,
      wordIds: List<String>.from(json['wordIds'] as List? ?? []),
      objectives: List<String>.from(json['objectives'] as List? ?? []),
    );
  }
}

/// Alphabet data for non-Latin scripts.
class AlphabetData {
  final String scriptName;
  final int letterCount;
  final List<LetterData> letters;

  const AlphabetData({
    required this.scriptName,
    required this.letterCount,
    required this.letters,
  });

  factory AlphabetData.fromJson(Map<String, dynamic> json) {
    return AlphabetData(
      scriptName: json['scriptName'] as String? ?? '',
      letterCount: (json['letterCount'] as num?)?.toInt() ?? 0,
      letters: (json['letters'] as List?)
              ?.map((l) => LetterData.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LetterData {
  final String character;
  final String romanization;
  final String pronunciationGuide;
  final String exampleWord;
  final String exampleTranslation;
  final String exampleTransliteration;

  const LetterData({
    required this.character,
    required this.romanization,
    required this.pronunciationGuide,
    required this.exampleWord,
    required this.exampleTranslation,
    required this.exampleTransliteration,
  });

  factory LetterData.fromJson(Map<String, dynamic> json) {
    return LetterData(
      character: json['character'] as String? ?? '',
      romanization: json['romanization'] as String? ?? '',
      pronunciationGuide: json['pronunciationGuide'] as String? ?? '',
      exampleWord: json['exampleWord'] as String? ?? '',
      exampleTranslation: json['exampleTranslation'] as String? ?? '',
      exampleTransliteration: json['exampleTransliteration'] as String? ?? '',
    );
  }
}

/// Dialogue for listening practice.
class DialogueData {
  final String id;
  final String title;
  final String level;
  final List<DialogueLineData> lines;
  final List<QuizQuestionData> questions;

  const DialogueData({
    required this.id,
    required this.title,
    required this.level,
    required this.lines,
    required this.questions,
  });

  factory DialogueData.fromJson(Map<String, dynamic> json) {
    return DialogueData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      level: json['level'] as String? ?? 'A1',
      lines: (json['lines'] as List?)
              ?.map(
                  (l) => DialogueLineData.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      questions: (json['questions'] as List?)
              ?.map(
                  (q) => QuizQuestionData.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DialogueLineData {
  final String speaker;
  final String target;
  final String transliteration;
  final String english;

  const DialogueLineData({
    required this.speaker,
    required this.target,
    required this.transliteration,
    required this.english,
  });

  factory DialogueLineData.fromJson(Map<String, dynamic> json) {
    return DialogueLineData(
      speaker: json['speaker'] as String? ?? '',
      target: json['target'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      english: json['english'] as String? ?? '',
    );
  }
}

/// Phrase for speaking practice.
class PhraseData {
  final String id;
  final String target;
  final String transliteration;
  final String english;
  final String level;
  final String context;

  const PhraseData({
    required this.id,
    required this.target,
    required this.transliteration,
    required this.english,
    required this.level,
    required this.context,
  });

  factory PhraseData.fromJson(Map<String, dynamic> json) {
    return PhraseData(
      id: json['id'] as String? ?? '',
      target: json['target'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      english: json['english'] as String? ?? '',
      level: json['level'] as String? ?? 'A1',
      context: json['context'] as String? ?? '',
    );
  }
}

/// Reading text.
class ReadingData {
  final String id;
  final String title;
  final String target;
  final String english;
  final String level;
  final List<QuizQuestionData> questions;

  const ReadingData({
    required this.id,
    required this.title,
    required this.target,
    required this.english,
    required this.level,
    required this.questions,
  });

  factory ReadingData.fromJson(Map<String, dynamic> json) {
    return ReadingData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      target: json['target'] as String? ?? '',
      english: json['english'] as String? ?? '',
      level: json['level'] as String? ?? 'A1',
      questions: (json['questions'] as List?)
              ?.map(
                  (q) => QuizQuestionData.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Writing exercise.
class WritingData {
  final String id;
  final String type; // 'translate', 'fill_blank', 'sentence_build'
  final String prompt;
  final String answer;
  final String? hint;
  final String level;

  const WritingData({
    required this.id,
    required this.type,
    required this.prompt,
    required this.answer,
    this.hint,
    required this.level,
  });

  factory WritingData.fromJson(Map<String, dynamic> json) {
    return WritingData(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'translate',
      prompt: json['prompt'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      hint: json['hint'] as String?,
      level: json['level'] as String? ?? 'A1',
    );
  }
}
