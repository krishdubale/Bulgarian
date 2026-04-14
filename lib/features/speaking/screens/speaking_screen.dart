import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/content_loader.dart';
import '../../../core/services/language_manager.dart';
import '../../../core/repositories/progress_repository.dart';

class SpeakingScreen extends ConsumerStatefulWidget {
  const SpeakingScreen({super.key});

  @override
  ConsumerState<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends ConsumerState<SpeakingScreen> {
  String _selectedLevel = 'A1';

  @override
  Widget build(BuildContext context) {
    final langId = ref.watch(selectedLanguageProvider).id;
    final phrasesAsync = ref.watch(phrasesProvider(langId));
    final progress = ref.watch(userProgressProvider);
    final theme = Theme.of(context);

    return phrasesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Speaking Practice')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Speaking Practice')),
        body: Center(child: Text('Error loading phrases: $e')),
      ),
      data: (allPhrases) {
        final phrases = allPhrases
            .where((p) => p.level == _selectedLevel)
            .toList();

        final practicedCount = phrases
            .where((p) => progress.practicedItems
                .contains('speaking_${p.target}'))
            .length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Speaking Practice'),
          ),
          body: Column(
            children: [
              // Level selector
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _levelChip('A1', theme),
                    const SizedBox(width: 8),
                    _levelChip('A2', theme),
                    const SizedBox(width: 8),
                    _levelChip('B1', theme),
                    const Spacer(),
                    Text(
                      '$practicedCount/${phrases.length} practiced',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: phrases.isEmpty
                    ? const Center(child: Text('No phrases for this level'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: phrases.length,
                        itemBuilder: (context, index) {
                          final phrase = phrases[index];
                          final itemId = 'speaking_${phrase.target}';
                          final isPracticed =
                              progress.practicedItems.contains(itemId);

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          phrase.target,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (isPracticed)
                                        const Icon(Icons.check_circle,
                                            color: Colors.green, size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    phrase.transliteration,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    phrase.english,
                                    style: TextStyle(
                                      color: theme.colorScheme.secondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (phrase.context.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.08),
                                      ),
                                      child: Text(
                                        '💬 ${phrase.context}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: theme.colorScheme
                                                    .primary),
                                      ),
                                    ),
                                  ],
                                  if (!isPracticed) ...[
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        icon: const Icon(
                                            Icons.record_voice_over,
                                            size: 16),
                                        label: const Text(
                                            'Mark as Practiced'),
                                        onPressed: () {
                                          ref
                                              .read(userProgressProvider
                                                  .notifier)
                                              .markItemPracticed(itemId);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _levelChip(String level, ThemeData theme) {
    final isSelected = _selectedLevel == level;
    return ChoiceChip(
      label: Text(level),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedLevel = level),
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
