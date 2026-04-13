import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/content_loader.dart';
import '../../../data/services/language_manager.dart';
import '../../../data/repositories/progress_repository.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'Greetings');

final categoryWordsProvider = Provider.family<List<ContentWord>, String>(
  (ref, category) {
    final langId = ref.watch(selectedLanguageProvider).id;
    final vocabAsync = ref.watch(vocabularyProvider(langId));
    return vocabAsync.whenOrNull(
          data: (categories) => categories
              .expand((c) => c.words)
              .where((w) => w.category == category)
              .toList(),
        ) ??
        [];
  },
);

final learnedWordsProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  final learnedWordIds = await repo.getLearnedWordIds();
  return learnedWordIds.toSet();
});

final flashcardIndexProvider = StateProvider<int>((ref) => 0);
final isFlippedProvider = StateProvider<bool>((ref) => false);
