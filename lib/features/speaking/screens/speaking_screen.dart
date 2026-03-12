import 'package:flutter/material.dart';
import '../../../core/constants/bulgarian_data.dart';

class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({super.key});

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  String _selectedLevel = 'All';
  int? _expandedIndex;

  List<SpeakingPhrase> get _filtered {
    if (_selectedLevel == 'All') return BulgarianData.speakingPhrases;
    return BulgarianData.speakingPhrases
        .where((p) => p.level == _selectedLevel)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levels = ['All', 'A1', 'A2', 'B1'];
    final phrases = _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Speaking Practice')),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: levels.map((level) {
                  final isSelected = level == _selectedLevel;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(level),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedLevel = level),
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 16, color: Colors.amber),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tap a phrase to expand it. Read aloud and practice!',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: phrases.length,
              itemBuilder: (context, index) {
                final phrase = phrases[index];
                final isExpanded = _expandedIndex == index;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() =>
                        _expandedIndex = isExpanded ? null : index),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                ),
                                child: Text(
                                  phrase.level,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            phrase.bulgarian,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            phrase.transliteration,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (isExpanded) ...[
                            const Divider(height: 20),
                            Row(
                              children: [
                                const Icon(Icons.translate,
                                    size: 16, color: Colors.blue),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    phrase.english,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                            color: theme
                                                .colorScheme.secondary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    size: 16, color: Colors.orange),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Context: ${phrase.context}',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                            color: Colors.orange[700]),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.green.withOpacity(0.08),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.mic,
                                      color: Colors.green, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Say it aloud!',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
