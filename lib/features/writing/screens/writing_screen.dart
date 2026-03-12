import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/bulgarian_data.dart';
import '../../../data/repositories/progress_repository.dart';

class WritingScreen extends ConsumerStatefulWidget {
  const WritingScreen({super.key});

  @override
  ConsumerState<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends ConsumerState<WritingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _exerciseIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  bool _showAnswer = false;
  bool _correct = false;
  bool _checked = false;

  List<WritingExercise> get _translationExercises =>
      BulgarianData.writingExercises
          .where((e) => e.type == 'translate')
          .toList();

  List<WritingExercise> get _fillBlankExercises =>
      BulgarianData.writingExercises
          .where((e) => e.type == 'fill_blank')
          .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _exerciseIndex = 0;
        _answerController.clear();
        _showAnswer = false;
        _checked = false;
        _correct = false;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Practice'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.translate), text: 'Translate'),
            Tab(icon: Icon(Icons.edit), text: 'Fill Blank'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExerciseTab(_translationExercises),
          _buildExerciseTab(_fillBlankExercises),
        ],
      ),
    );
  }

  Widget _buildExerciseTab(List<WritingExercise> exercises) {
    if (exercises.isEmpty) {
      return const Center(child: Text('No exercises available'));
    }

    if (_exerciseIndex >= exercises.length) {
      return _buildAllDone(exercises);
    }

    final exercise = exercises[_exerciseIndex];
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        LinearProgressIndicator(
          value: (_exerciseIndex + 1) / exercises.length,
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
        ),
        const SizedBox(height: 8),
        Text(
          'Exercise ${_exerciseIndex + 1} of ${exercises.length}',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.primary.withOpacity(0.08),
            border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    exercise.type == 'translate'
                        ? Icons.translate
                        : Icons.edit,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    exercise.type == 'translate'
                        ? 'Translation Exercise'
                        : 'Fill in the Blank',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                exercise.prompt,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _answerController,
          enabled: !_checked,
          decoration: InputDecoration(
            hintText: 'Your answer in Bulgarian...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: theme.colorScheme.primary, width: 2),
            ),
            filled: true,
            fillColor: _checked
                ? (_correct
                    ? Colors.green.withOpacity(0.08)
                    : Colors.red.withOpacity(0.08))
                : null,
            suffixIcon: _checked
                ? Icon(
                    _correct ? Icons.check_circle : Icons.cancel,
                    color: _correct ? Colors.green : Colors.red,
                  )
                : null,
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _checkAnswer(exercise),
        ),
        if (exercise.hint != null && !_checked) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.lightbulb_outline,
                  size: 15, color: Colors.amber),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Hint: ${exercise.hint}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.amber[700]),
                ),
              ),
            ],
          ),
        ],
        if (_checked) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _correct
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _correct ? '✅ Correct!' : '💡 Correct answer:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _correct ? Colors.green : Colors.orange,
                  ),
                ),
                if (!_correct) ...[
                  const SizedBox(height: 4),
                  Text(
                    exercise.answer,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (!_checked)
          ElevatedButton(
            onPressed: () => _checkAnswer(exercise),
            child: const Text('Check Answer'),
          )
        else
          ElevatedButton(
            onPressed: () {
              _answerController.clear();
              setState(() {
                _exerciseIndex++;
                _showAnswer = false;
                _checked = false;
                _correct = false;
              });
            },
            child: Text(
              _exerciseIndex + 1 < exercises.length ? 'Next →' : 'Finish',
            ),
          ),
        const SizedBox(height: 12),
        if (!_checked)
          TextButton(
            onPressed: () => setState(() => _showAnswer = !_showAnswer),
            child: Text(
              _showAnswer ? 'Hide answer' : 'Reveal answer',
            ),
          ),
        if (_showAnswer && !_checked)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              exercise.answer,
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  void _checkAnswer(WritingExercise exercise) {
    final userInput = _answerController.text.trim().toLowerCase();
    final correctAnswer = exercise.answer.trim().toLowerCase();
    // Simple normalization: ignore trailing punctuation
    final clean =
        (String s) => s.replaceAll(RegExp(r'[.!?]$'), '').trim();
    setState(() {
      _correct = clean(userInput) == clean(correctAnswer);
      _checked = true;
    });
    if (_correct) {
      ref.read(userProgressProvider.notifier).addXp(5);
    }
  }

  Widget _buildAllDone(List<WritingExercise> exercises) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 72, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'All exercises complete!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Practice Again'),
              onPressed: () {
                _answerController.clear();
                setState(() {
                  _exerciseIndex = 0;
                  _showAnswer = false;
                  _checked = false;
                  _correct = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
