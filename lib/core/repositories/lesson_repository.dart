import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_model.dart';
import '../services/content_loader.dart';
import '../services/language_manager.dart';

/// Provider that exposes lessons for the currently selected language.
final lessonListProvider = FutureProvider<List<LessonModel>>((ref) async {
  final langId = ref.watch(selectedLanguageProvider).id;
  final loader = ref.watch(contentLoaderProvider);
  final definitions = await loader.loadLessons(langId);

  return definitions.map((d) => LessonModel(
    id: d.id,
    title: d.title,
    description: d.description,
    level: d.level,
    category: d.category,
    xpReward: d.xpReward,
    wordIds: d.wordIds,
  )).toList();
});

class LessonRepository {
  final ContentLoader _loader;

  LessonRepository(this._loader);

  /// Loads lessons for the given language from JSON content.
  Future<List<LessonModel>> getLessons(String languageId) async {
    final definitions = await _loader.loadLessons(languageId);
    return definitions.map((d) => LessonModel(
      id: d.id,
      title: d.title,
      description: d.description,
      level: d.level,
      category: d.category,
      xpReward: d.xpReward,
      wordIds: d.wordIds,
    )).toList();
  }
}
