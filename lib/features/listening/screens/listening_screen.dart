import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/content_loader.dart';
import '../../../core/services/language_manager.dart';
import '../../../core/repositories/progress_repository.dart';

class ListeningScreen extends ConsumerStatefulWidget {
  const ListeningScreen({super.key});

  @override
  ConsumerState<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends ConsumerState<ListeningScreen> {
  int _selectedDialogue = 0;
  bool _showTranslation = false;
  int? _quizAnswer;
  int _quizQuestion = 0;
  bool _inQuiz = false;
  int _score = 0;
  bool _quizDone = false;

  @override
  Widget build(BuildContext context) {
    final langId = ref.watch(selectedLanguageProvider).id;
    final dialoguesAsync = ref.watch(dialoguesProvider(langId));

    return dialoguesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Listening Practice')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Listening Practice')),
        body: Center(child: Text('Error loading dialogues: $e')),
      ),
      data: (dialogues) {
        if (dialogues.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Listening Practice')),
            body: const Center(child: Text('No dialogues available')),
          );
        }

        if (_selectedDialogue >= dialogues.length) {
          _selectedDialogue = 0;
        }

        final dialogue = dialogues[_selectedDialogue];

        return Scaffold(
          appBar: AppBar(title: const Text('Listening Practice')),
          body: Column(
            children: [
              // Dialogue selector
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: dialogues.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedDialogue;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(dialogues[index].title),
                        selected: isSelected,
                        onSelected: (_) => setState(() {
                          _selectedDialogue = index;
                          _showTranslation = false;
                          _inQuiz = false;
                          _quizQuestion = 0;
                          _quizAnswer = null;
                          _score = 0;
                          _quizDone = false;
                        }),
                        selectedColor:
                            Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _inQuiz
                    ? _buildQuiz(dialogue)
                    : _buildDialogue(dialogue),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogue(DialogueData dialogue) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Chip(
              label: Text('Level: ${dialogue.level}'),
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            TextButton.icon(
              icon: Icon(_showTranslation
                  ? Icons.visibility_off
                  : Icons.visibility),
              label: Text(_showTranslation
                  ? 'Hide translation'
                  : 'Show translation'),
              onPressed: () =>
                  setState(() => _showTranslation = !_showTranslation),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...dialogue.lines.map(
          (line) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.15),
                      child: Text(
                        line.speaker.isNotEmpty
                            ? line.speaker.substring(0, 1)
                            : '?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      line.speaker,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  line.target,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  line.transliteration,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                if (_showTranslation) ...[
                  const SizedBox(height: 4),
                  Text(
                    line.english,
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (dialogue.questions.isNotEmpty)
          ElevatedButton.icon(
            icon: const Icon(Icons.quiz),
            label: const Text('Take Comprehension Quiz'),
            onPressed: () => setState(() {
              _inQuiz = true;
              _quizQuestion = 0;
              _quizAnswer = null;
              _score = 0;
              _quizDone = false;
            }),
          ),
      ],
    );
  }

  Widget _buildQuiz(DialogueData dialogue) {
    if (_quizDone) {
      final pct =
          (_score / dialogue.questions.length * 100).round();
      final lessonId = 'listening_$_selectedDialogue';
      final progress = ref.watch(userProgressProvider);
      final alreadyCompleted =
          progress.completedLessons.contains(lessonId);

      if (!alreadyCompleted && _score > 0) {
        Future.microtask(() {
          ref
              .read(userProgressProvider.notifier)
              .addQuizXp(lessonId, _score, dialogue.questions.length);
        });
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                pct >= 50 ? Icons.emoji_events : Icons.refresh,
                size: 64,
                color: pct >= 50 ? Colors.amber : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '$pct%',
                style: const TextStyle(
                    fontSize: 48, fontWeight: FontWeight.bold),
              ),
              Text('$_score / ${dialogue.questions.length} correct',
                  style: Theme.of(context).textTheme.titleLarge),
              if (alreadyCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '✓ Previously completed',
                    style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontStyle: FontStyle.italic,
                            ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _inQuiz = false),
                child: const Text('Back to Dialogue'),
              ),
            ],
          ),
        ),
      );
    }

    final q = dialogue.questions[_quizQuestion];
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value:
                (_quizQuestion + 1) / dialogue.questions.length,
            color: theme.colorScheme.primary,
            backgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),
          Text(
            'Question ${_quizQuestion + 1} of ${dialogue.questions.length}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            q.question,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ...q.options.asMap().entries.map((entry) {
            final idx = entry.key;
            final opt = entry.value;
            final isCorrect = idx == q.correctIndex;
            Color? bg;
            BorderSide borderSide;

            if (_quizAnswer != null) {
              if (isCorrect) {
                bg = Colors.green.withValues(alpha: 0.15);
                borderSide = const BorderSide(color: Colors.green);
              } else if (idx == _quizAnswer && !isCorrect) {
                bg = Colors.red.withValues(alpha: 0.15);
                borderSide = const BorderSide(color: Colors.red);
              } else {
                borderSide = BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3));
              }
            } else {
              borderSide =
                  BorderSide(color: theme.colorScheme.primary);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _quizAnswer == null
                      ? () => setState(() {
                            _quizAnswer = idx;
                            if (isCorrect) _score++;
                          })
                      : null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: bg,
                    side: borderSide,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(opt),
                  ),
                ),
              ),
            );
          }),
          if (_quizAnswer != null)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (_quizQuestion + 1 >=
                      dialogue.questions.length) {
                    setState(() => _quizDone = true);
                  } else {
                    setState(() {
                      _quizQuestion++;
                      _quizAnswer = null;
                    });
                  }
                },
                child: Text(
                  _quizQuestion + 1 >= dialogue.questions.length
                      ? 'Finish'
                      : 'Next',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
