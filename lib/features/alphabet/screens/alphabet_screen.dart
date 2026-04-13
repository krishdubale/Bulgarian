import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/content_loader.dart';
import '../../../data/services/language_manager.dart';
import '../../../data/repositories/progress_repository.dart';

class AlphabetScreen extends ConsumerStatefulWidget {
  const AlphabetScreen({super.key});

  @override
  ConsumerState<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends ConsumerState<AlphabetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LetterData? _selectedLetter;
  int _quizIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;
  bool _quizFinished = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langId = ref.watch(selectedLanguageProvider).id;
    final alphabetAsync = ref.watch(alphabetProvider(langId));

    return alphabetAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Alphabet Trainer')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Alphabet Trainer')),
        body: Center(child: Text('Error loading alphabet: $e')),
      ),
      data: (alphabetData) {
        if (alphabetData == null || alphabetData.letters.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Alphabet Trainer')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'This language uses the Latin alphabet.\nNo special alphabet training needed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final letters = alphabetData.letters;

        return Scaffold(
          appBar: AppBar(
            title: Text('${alphabetData.scriptName} Trainer'),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.grid_view), text: 'Letters'),
                Tab(icon: Icon(Icons.quiz), text: 'Quiz'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildLettersTab(letters),
              _buildQuizTab(letters),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLettersTab(List<LetterData> letters) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemCount: letters.length,
            itemBuilder: (context, index) {
              final letter = letters[index];
              final isSelected = _selectedLetter == letter;
              return GestureDetector(
                onTap: () => setState(() => _selectedLetter = letter),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      letter.character,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_selectedLetter != null)
          Expanded(
            flex: 4,
            child: _LetterDetailPanel(letter: _selectedLetter!),
          ),
      ],
    );
  }

  Widget _buildQuizTab(List<LetterData> letters) {
    if (_quizFinished) {
      return _buildQuizResults(letters);
    }

    if (_quizIndex >= letters.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _quizFinished = true);
      });
      return const Center(child: CircularProgressIndicator());
    }

    final current = letters[_quizIndex];
    // Generate 4 options: correct + 3 random
    final options = <String>[current.romanization];
    final others = letters
        .where((l) => l.romanization != current.romanization)
        .map((l) => l.romanization)
        .toList()
      ..shuffle();
    options.addAll(others.take(3));
    options.shuffle();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Letter ${_quizIndex + 1} of ${letters.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _quizIndex / letters.length,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 40),
          Text(
            current.character,
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What is the romanization of this letter?',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;
            final isCorrect = option == current.romanization;
            Color? bgColor;
            BorderSide borderSide;

            if (_selectedAnswerIndex != null) {
              if (isCorrect) {
                bgColor = Colors.green.withValues(alpha: 0.15);
                borderSide = const BorderSide(color: Colors.green);
              } else if (idx == _selectedAnswerIndex && !isCorrect) {
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
              borderSide =
                  BorderSide(color: Theme.of(context).colorScheme.primary);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _selectedAnswerIndex == null
                      ? () => _answerQuestion(idx, isCorrect)
                      : null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: bgColor,
                    side: borderSide,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 18)),
                ),
              ),
            );
          }),
          if (_selectedAnswerIndex != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ElevatedButton(
                onPressed: () => _nextQuestion(letters),
                child: Text(
                  _quizIndex + 1 < letters.length ? 'Next →' : 'Finish',
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _answerQuestion(int idx, bool isCorrect) {
    setState(() {
      _selectedAnswerIndex = idx;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion(List<LetterData> letters) {
    setState(() {
      _selectedAnswerIndex = null;
      _quizIndex++;
      if (_quizIndex >= letters.length) {
        _quizFinished = true;
      }
    });
  }

  Widget _buildQuizResults(List<LetterData> letters) {
    final total = letters.length;
    final pct = (_score / total * 100).round();
    final progress = ref.read(userProgressProvider);
    final alreadyCompleted =
        progress.completedLessons.contains('alphabet_quiz');

    if (!alreadyCompleted && _score > 0) {
      Future.microtask(() {
        ref
            .read(userProgressProvider.notifier)
            .addQuizXp('alphabet_quiz', _score, total, baseXp: 20);
      });
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              pct >= 70 ? Icons.emoji_events : Icons.refresh,
              size: 72,
              color: pct >= 70 ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '$pct%',
              style: const TextStyle(
                  fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$_score / $total correct',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              pct >= 70
                  ? '🎉 Great job! You know the alphabet well!'
                  : 'Keep practicing – you\'ll get it!',
              textAlign: TextAlign.center,
            ),
            if (alreadyCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '✓ Previously completed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () {
                setState(() {
                  _quizIndex = 0;
                  _score = 0;
                  _selectedAnswerIndex = null;
                  _quizFinished = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterDetailPanel extends StatelessWidget {
  final LetterData letter;
  const _LetterDetailPanel({required this.letter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            letter.character,
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          _Row(label: 'Romanization', value: letter.romanization),
          _Row(label: 'Pronunciation', value: letter.pronunciationGuide),
          _Row(label: 'Example word', value: letter.exampleWord),
          _Row(
              label: 'Transliteration',
              value: letter.exampleTransliteration),
          _Row(label: 'English', value: letter.exampleTranslation),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  )),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
