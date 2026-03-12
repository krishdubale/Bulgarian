import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/bulgarian_data.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/progress_repository.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'Greetings');

final categoryWordsProvider = Provider.family<List<BulgarianWord>, String>(
  (ref, category) {
    return BulgarianData.vocabulary
        .where((w) => w.category == category)
        .toList();
  },
);

final learnedWordsProvider = StateProvider<Set<String>>((ref) {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.getLearnedWordIds().toSet();
});

final flashcardIndexProvider = StateProvider<int>((ref) => 0);
final isFlippedProvider = StateProvider<bool>((ref) => false);
