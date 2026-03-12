import 'package:flutter/material.dart';
import '../../../core/constants/bulgarian_data.dart';

class AlphabetScreen extends StatefulWidget {
  const AlphabetScreen({super.key});

  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BulgarianLetter? _selectedLetter;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alphabet Trainer'),
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
          _buildLettersTab(),
          _buildQuizTab(),
        ],
      ),
    );
  }

  Widget _buildLettersTab() {
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
            itemCount: BulgarianData.alphabet.length,
            itemBuilder: (context, index) {
              final letter = BulgarianData.alphabet[index];
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
                            .withOpacity(0.1),
                  ),
                  child: Center(
                    child: Text(
                      letter.cyrillic,
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

  Widget _buildQuizTab() {
    if (_quizFinished) {
      return _buildQuizResults();
    }

    final letters = BulgarianData.alphabet;
    if (_quizIndex >= letters.length) {
      setState(() => _quizFinished = true);
      return _buildQuizResults();
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
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 40),
          Text(
            current.cyrillic,
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
            if (_selectedAnswerIndex != null) {
              if (isCorrect) {
                bgColor = Colors.green.withOpacity(0.15);
              } else if (idx == _selectedAnswerIndex && !isCorrect) {
                bgColor = Colors.red.withOpacity(0.15);
              }
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
                    side: BorderSide(
                      color: bgColor != null
                          ? (isCorrect ? Colors.green : Colors.red)
                          : Theme.of(context).colorScheme.primary,
                    ),
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
                onPressed: _nextQuestion,
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

  void _nextQuestion() {
    setState(() {
      _selectedAnswerIndex = null;
      _quizIndex++;
      if (_quizIndex >= BulgarianData.alphabet.length) {
        _quizFinished = true;
      }
    });
  }

  Widget _buildQuizResults() {
    final total = BulgarianData.alphabet.length;
    final pct = (_score / total * 100).round();
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
  final BulgarianLetter letter;
  const _LetterDetailPanel({required this.letter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        color: theme.colorScheme.primary.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            letter.cyrillic,
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          _Row(label: 'Romanization', value: letter.romanization),
          _Row(label: 'Pronunciation', value: letter.pronunciationGuide),
          _Row(label: 'Example word', value: letter.exampleWordBulgarian),
          _Row(label: 'Transliteration', value: letter.exampleWordTransliteration),
          _Row(label: 'English', value: letter.exampleWordEnglish),
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
