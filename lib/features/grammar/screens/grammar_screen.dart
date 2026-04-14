import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/content_loader.dart';
import '../../../core/services/language_manager.dart';
import '../../../core/repositories/progress_repository.dart';

class GrammarScreen extends ConsumerStatefulWidget {
  const GrammarScreen({super.key});

  @override
  ConsumerState<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends ConsumerState<GrammarScreen> {
  int? _quizTopicIndex;
  int _quizQuestionIndex = 0;
  int? _selectedAnswer;
  int _score = 0;
  bool _quizDone = false;

  @override
  Widget build(BuildContext context) {
    final langId = ref.watch(selectedLanguageProvider).id;
    final grammarAsync = ref.watch(grammarProvider(langId));

    return grammarAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Grammar Lessons')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Grammar Lessons')),
        body: Center(child: Text('Error loading grammar: $e')),
      ),
      data: (topics) {
        if (_quizTopicIndex != null && !_quizDone) {
          return _buildQuiz(topics[_quizTopicIndex!]);
        }
        if (_quizDone) {
          return _buildQuizResult(topics[_quizTopicIndex!]);
        }
        return _buildTopicList(topics);
      },
    );
  }

  Widget _buildTopicList(List<GrammarTopicData> topics) {
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Lessons')),
      body: topics.isEmpty
          ? const Center(child: Text('No grammar topics available'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: topics.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final topic = topics[index];
                final lessonId = 'grammar_$index';
                final isCompleted =
                    progress.completedLessons.contains(lessonId);

                return _GrammarTopicCard(
                  topic: topic,
                  isCompleted: isCompleted,
                  onStartQuiz: () {
                    setState(() {
                      _quizTopicIndex = index;
                      _quizQuestionIndex = 0;
                      _selectedAnswer = null;
                      _score = 0;
                      _quizDone = false;
                    });
                  },
                );
              },
            ),
    );
  }

  Widget _buildQuiz(GrammarTopicData topic) {
    final question = topic.quiz[_quizQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${topic.title}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() {
            _quizTopicIndex = null;
            _quizDone = false;
          }),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_quizQuestionIndex + 1) / topic.quiz.length,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Question ${_quizQuestionIndex + 1} of ${topic.quiz.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ...question.options.asMap().entries.map((entry) {
              final idx = entry.key;
              final option = entry.value;
              final isCorrect = idx == question.correctIndex;
              Color? bgColor;
              BorderSide borderSide;

              if (_selectedAnswer != null) {
                if (isCorrect) {
                  bgColor = Colors.green.withValues(alpha: 0.15);
                  borderSide = const BorderSide(color: Colors.green);
                } else if (idx == _selectedAnswer) {
                  bgColor = Colors.red.withValues(alpha: 0.15);
                  borderSide = const BorderSide(color: Colors.red);
                } else {
                  borderSide = BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3));
                }
              } else {
                borderSide = BorderSide(
                    color: Theme.of(context).colorScheme.primary);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _selectedAnswer == null
                        ? () => setState(() {
                              _selectedAnswer = idx;
                              if (isCorrect) _score++;
                            })
                        : null,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: bgColor,
                      side: borderSide,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(option),
                    ),
                  ),
                ),
              );
            }),
            if (_selectedAnswer != null)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    if (_quizQuestionIndex + 1 >= topic.quiz.length) {
                      setState(() => _quizDone = true);
                      final lessonId = 'grammar_$_quizTopicIndex';
                      ref
                          .read(userProgressProvider.notifier)
                          .addQuizXp(lessonId, _score, topic.quiz.length);
                    } else {
                      setState(() {
                        _quizQuestionIndex++;
                        _selectedAnswer = null;
                      });
                    }
                  },
                  child: Text(
                    _quizQuestionIndex + 1 >= topic.quiz.length
                        ? 'Finish'
                        : 'Next',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizResult(GrammarTopicData topic) {
    final pct = (_score / topic.quiz.length * 100).round();
    final lessonId = 'grammar_$_quizTopicIndex';
    final progress = ref.watch(userProgressProvider);
    final alreadyCompleted = progress.completedLessons.contains(lessonId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                pct >= 50 ? Icons.emoji_events : Icons.refresh,
                size: 72,
                color: pct >= 50 ? Colors.amber : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '$pct%',
                style: const TextStyle(
                    fontSize: 48, fontWeight: FontWeight.bold),
              ),
              Text('$_score / ${topic.quiz.length} correct'),
              if (alreadyCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '✓ Previously completed — no XP awarded',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    setState(() => _quizTopicIndex = null),
                child: const Text('Back to Topics'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrammarTopicCard extends StatefulWidget {
  final GrammarTopicData topic;
  final bool isCompleted;
  final VoidCallback onStartQuiz;

  const _GrammarTopicCard({
    required this.topic,
    required this.isCompleted,
    required this.onStartQuiz,
  });

  @override
  State<_GrammarTopicCard> createState() => _GrammarTopicCardState();
}

class _GrammarTopicCardState extends State<_GrammarTopicCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topic = widget.topic;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: widget.isCompleted
                  ? Colors.green.withValues(alpha: 0.15)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              child: widget.isCompleted
                  ? const Icon(Icons.check, color: Colors.green, size: 18)
                  : Text(
                      topic.level,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            title: Text(
              topic.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              color: theme.colorScheme.primary,
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.explanation,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Examples',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...topic.examples.map(
                    (ex) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.06),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ex.target,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text(ex.transliteration,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic)),
                          Text(ex.english,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.quiz),
                      label: Text(widget.isCompleted
                          ? 'Retake Quiz'
                          : 'Take Quiz'),
                      onPressed: widget.onStartQuiz,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
