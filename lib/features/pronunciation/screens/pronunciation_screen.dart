import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/content_loader.dart';
import '../../../core/services/language_manager.dart';
import '../../../core/repositories/progress_repository.dart';

class PronunciationScreen extends ConsumerWidget {
  const PronunciationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final theme = Theme.of(context);
    final langId = ref.watch(selectedLanguageProvider).id;
    final alphabetAsync = ref.watch(alphabetProvider(langId));

    return alphabetAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Pronunciation Guide')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Pronunciation Guide')),
        body: Center(child: Text('Error loading alphabet: $e')),
      ),
      data: (alphabetData) {
        if (alphabetData == null || alphabetData.letters.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pronunciation Guide')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No pronunciation data available\nfor this language yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final letters = alphabetData.letters;
        final practicedCount = _practicedCount(progress, letters);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pronunciation Guide'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.record_voice_over,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '$practicedCount/${letters.length} letters practiced',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: letters.length,
            itemBuilder: (context, index) {
              final letter = letters[index];
              final itemId = 'pronunciation_${letter.character}';
              final isPracticed =
                  progress.practicedItems.contains(itemId);

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPracticed
                        ? Colors.green.withValues(alpha: 0.15)
                        : theme.colorScheme.primary
                            .withValues(alpha: 0.1),
                    child: isPracticed
                        ? const Icon(Icons.check,
                            color: Colors.green, size: 18)
                        : Text(
                            letter.character,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        '${letter.character}  →  ${letter.romanization}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        letter.pronunciationGuide,
                        style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${letter.exampleWord} (${letter.exampleTransliteration}) — ${letter.exampleTranslation}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: isPracticed
                      ? const Icon(Icons.check_circle,
                          color: Colors.green, size: 20)
                      : OutlinedButton(
                          onPressed: () {
                            ref
                                .read(userProgressProvider.notifier)
                                .markItemPracticed(itemId);
                          },
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 32),
                          ),
                          child: const Text('Practice',
                              style: TextStyle(fontSize: 11)),
                        ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        );
      },
    );
  }

  int _practicedCount(dynamic progress, List<LetterData> letters) {
    int count = 0;
    for (final l in letters) {
      if (progress.practicedItems
          .contains('pronunciation_${l.character}')) {
        count++;
      }
    }
    return count;
  }
}
