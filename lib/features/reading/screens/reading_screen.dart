import 'package:flutter/material.dart';
import '../../../core/constants/bulgarian_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/progress_repository.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  int _selectedText = 0;
  bool _showTranslation = false;
  bool _inQuiz = false;
  int _quizQuestion = 0;
  int? _quizAnswer;
  int _score = 0;
  bool _quizDone = false;

  @override
  Widget build(BuildContext context) {
    final text = BulgarianData.readingTexts[_selectedText];

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Practice')),
      body: Column(
        children: [
          // Text selector
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: BulgarianData.readingTexts.length,
              itemBuilder: (context, index) {
                final t = BulgarianData.readingTexts[index];
                final isSelected = index == _selectedText;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t.title),
                    selected: isSelected,
                    onSelected: (_) => setState(() {
                      _selectedText = index;
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
                ? _buildQuiz(text)
                : _buildTextView(text),
          ),
        ],
      ),
    );
  }

  Widget _buildTextView(ReadingText text) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Chip(
              label: Text('Level: ${text.level}'),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            ),
            TextButton.icon(
              icon: Icon(
                _showTranslation ? Icons.visibility_off : Icons.visibility,
              ),
              label: Text(
                _showTranslation ? 'Hide English' : 'Show English',
              ),
              onPressed: () =>
                  setState(() => _showTranslation = !_showTranslation),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              text.bulgarian,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ),
        if (_showTranslation) ...[
          const SizedBox(height: 12),
          Card(
            color: theme.colorScheme.secondary.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🇬🇧 Translation',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    text.english,
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
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

  Widget _buildQuiz(ReadingText text) {
    if (_quizDone) {
      final pct = (_score / text.questions.length * 100).round();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                pct >= 66 ? Icons.emoji_events : Icons.refresh,
                size: 64,
                color: pct >= 66 ? Colors.amber : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '$pct%',
                style: const TextStyle(
                    fontSize: 48, fontWeight: FontWeight.bold),
              ),
              Text('$_score / ${text.questions.length} correct'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _inQuiz = false),
                    child: const Text('Re-read'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(userProgressProvider.notifier)
                          .incrementLessons();
                      setState(() => _inQuiz = false);
                    },
                    child: const Text('Mark Complete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final q = text.questions[_quizQuestion];
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_quizQuestion + 1) / text.questions.length,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
          ),
          const SizedBox(height: 24),
          Text(
            'Question ${_quizQuestion + 1} of ${text.questions.length}',
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
            if (_quizAnswer != null) {
              if (isCorrect) bg = Colors.green.withOpacity(0.15);
              if (idx == _quizAnswer && !isCorrect)
                bg = Colors.red.withOpacity(0.15);
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
                    side: BorderSide(
                      color: _quizAnswer != null
                          ? (isCorrect ? Colors.green : Colors.red)
                          : theme.colorScheme.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
                  if (_quizQuestion + 1 >= text.questions.length) {
                    setState(() => _quizDone = true);
                  } else {
                    setState(() {
                      _quizQuestion++;
                      _quizAnswer = null;
                    });
                  }
                },
                child: Text(
                  _quizQuestion + 1 >= text.questions.length
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
