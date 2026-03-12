import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/bulgarian_data.dart';
import '../../../data/repositories/progress_repository.dart';

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
    if (_quizTopicIndex != null && !_quizDone) {
      return _buildQuiz(BulgarianData.grammarTopics[_quizTopicIndex!]);
    }
    if (_quizDone) {
      return _buildQuizResult(BulgarianData.grammarTopics[_quizTopicIndex!]);
    }
    return _buildTopicList();
  }

  Widget _buildTopicList() {
    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Lessons')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: BulgarianData.grammarTopics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final topic = BulgarianData.grammarTopics[index];
          return _GrammarTopicCard(
            topic: topic,
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

  Widget _buildQuiz(GrammarTopic topic) {
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
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
              if (_selectedAnswer != null) {
                if (isCorrect) {
                  bgColor = Colors.green.withOpacity(0.15);
                } else if (idx == _selectedAnswer) {
                  bgColor = Colors.red.withOpacity(0.15);
                }
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
                      side: BorderSide(
                        color: _selectedAnswer != null
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Theme.of(context).colorScheme.primary,
                      ),
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
                      ref
                          .read(userProgressProvider.notifier)
                          .incrementLessons();
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

  Widget _buildQuizResult(GrammarTopic topic) {
    final pct = (_score / topic.quiz.length * 100).round();
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
  final GrammarTopic topic;
  final VoidCallback onStartQuiz;

  const _GrammarTopicCard({
    required this.topic,
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
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
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
                        color: theme.colorScheme.primary.withOpacity(0.06),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ex.bulgarian,
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
                      label: const Text('Take Quiz'),
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
