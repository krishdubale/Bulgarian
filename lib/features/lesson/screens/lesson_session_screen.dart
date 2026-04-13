import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../data/models/lesson_session_model.dart';
import '../../../data/services/evaluation_service.dart';
import '../../../data/repositories/progress_repository.dart';

/// Full interactive lesson session screen.
/// Displays exercises one at a time with immediate feedback and a summary at the end.
class LessonSessionScreen extends ConsumerStatefulWidget {
  final LessonSession session;

  const LessonSessionScreen({super.key, required this.session});

  @override
  ConsumerState<LessonSessionScreen> createState() =>
      _LessonSessionScreenState();
}

class _LessonSessionScreenState extends ConsumerState<LessonSessionScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _answered = false;
  String? _selectedAnswer;
  final List<ExerciseResult> _results = [];
  DateTime? _exerciseStartTime;
  late AnimationController _feedbackController;
  late AnimationController _progressController;
  late Animation<double> _feedbackScale;

  @override
  void initState() {
    super.initState();
    _exerciseStartTime = DateTime.now();
    _feedbackController = AnimationController(
      vsync: this,
      duration: DesignTokens.animNormal,
    );
    _progressController = AnimationController(
      vsync: this,
      duration: DesignTokens.animSlow,
    );
    _feedbackScale = CurvedAnimation(
      parent: _feedbackController,
      curve: DesignTokens.animCurveBounce,
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  SessionExercise get _currentExercise =>
      widget.session.exercises[_currentIndex];

  double get _progress =>
      widget.session.exercises.isEmpty
          ? 0
          : (_currentIndex + (_answered ? 1 : 0)) /
              widget.session.exercises.length;

  bool get _isLastExercise =>
      _currentIndex >= widget.session.exercises.length - 1;

  void _selectAnswer(String answer) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
    });

    final isCorrect = answer.trim().toLowerCase() ==
        _currentExercise.correctAnswer.trim().toLowerCase();
    final responseTime =
        DateTime.now().difference(_exerciseStartTime ?? DateTime.now());

    _results.add(ExerciseResult(
      exerciseId: _currentExercise.id,
      itemId: _currentExercise.relatedItemId,
      isCorrect: isCorrect,
      userAnswer: answer,
      correctAnswer: _currentExercise.correctAnswer,
      responseTime: responseTime,
      exerciseType: _currentExercise.type,
    ));

    _feedbackController.forward(from: 0);
  }

  void _nextExercise() {
    if (_isLastExercise) {
      _showSummary();
      return;
    }
    setState(() {
      _currentIndex++;
      _answered = false;
      _selectedAnswer = null;
      _exerciseStartTime = DateTime.now();
    });
    _feedbackController.reset();
  }

  void _showSummary() async {
    final evaluationService = ref.read(evaluationServiceProvider);
    final progress = ref.read(userProgressProvider);

    final result = await evaluationService.evaluateSession(
      session: widget.session,
      answers: _results,
      streakDays: progress.streakDays,
    );

    // Update user XP.
    await ref.read(userProgressProvider.notifier).addXp(result.xpEarned);

    if (!mounted) return;

    // Navigate to summary.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SessionSummaryScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = _currentExercise;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with progress.
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _showExitDialog(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: _progress),
                      duration: DesignTokens.animNormal,
                      curve: DesignTokens.animCurveEnter,
                      builder: (context, value, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(
                              DesignTokens.radiusFull),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 10,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              value >= 1.0
                                  ? DesignTokens.success
                                  : DesignTokens.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentIndex + 1}/${widget.session.exercises.length}',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ),

            // Exercise content.
            Expanded(
              child: AnimatedSwitcher(
                duration: DesignTokens.animNormal,
                child: SingleChildScrollView(
                  key: ValueKey(_currentIndex),
                  padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: DesignTokens.spacingLg),
                      // Exercise type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: DesignTokens.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              DesignTokens.radiusFull),
                        ),
                        child: Text(
                          _exerciseTypeLabel(exercise.type),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: DesignTokens.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacingMd),

                      // Question
                      Text(
                        exercise.question,
                        style: theme.textTheme.headlineSmall,
                      ),
                      if (exercise.questionTransliteration != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          exercise.questionTransliteration!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: DesignTokens.textSecondaryLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: DesignTokens.spacingXl),

                      // Options (MCQ)
                      if (exercise.type == ExerciseType.mcq ||
                          exercise.options.isNotEmpty) ...[
                        ...exercise.options.map((option) =>
                            _buildOptionCard(option, exercise, theme)),
                      ],

                      // Fill blank / Translate input
                      if (exercise.type == ExerciseType.fillBlank ||
                          exercise.type == ExerciseType.translate) ...[
                        _buildTextInput(exercise, theme),
                      ],

                      // Sentence build
                      if (exercise.type == ExerciseType.sentenceBuild &&
                          exercise.wordBank != null) ...[
                        _buildSentenceBuilder(exercise, theme),
                      ],

                      const SizedBox(height: DesignTokens.spacingMd),

                      // Feedback area
                      if (_answered)
                        ScaleTransition(
                          scale: _feedbackScale,
                          child: _buildFeedback(exercise, theme),
                        ),

                      const SizedBox(height: DesignTokens.spacingXxl),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom continue button
            if (_answered)
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingMd),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCorrectAnswer()
                          ? DesignTokens.success
                          : DesignTokens.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      _isLastExercise ? 'See Results' : 'Continue',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      String option, SessionExercise exercise, ThemeData theme) {
    final isSelected = _selectedAnswer == option;
    final isCorrect =
        option.trim().toLowerCase() == exercise.correctAnswer.trim().toLowerCase();
    final showResult = _answered;

    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.transparent;
    IconData? trailingIcon;

    if (showResult && isCorrect) {
      borderColor = DesignTokens.success;
      bgColor = DesignTokens.successLight;
      trailingIcon = Icons.check_circle;
    } else if (showResult && isSelected && !isCorrect) {
      borderColor = DesignTokens.error;
      bgColor = DesignTokens.errorLight;
      trailingIcon = Icons.cancel;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
      child: AnimatedContainer(
        duration: DesignTokens.animNormal,
        curve: DesignTokens.animCurveEnter,
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: InkWell(
            onTap: _answered ? null : () => _selectAnswer(option),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            child: Container(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (trailingIcon != null)
                    Icon(
                      trailingIcon,
                      color: isCorrect ? DesignTokens.success : DesignTokens.error,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(SessionExercise exercise, ThemeData theme) {
    final controller = TextEditingController();
    return Column(
      children: [
        TextField(
          controller: controller,
          enabled: !_answered,
          decoration: InputDecoration(
            hintText: 'Type your answer...',
            suffixIcon: !_answered
                ? IconButton(
                    icon: const Icon(Icons.send, color: DesignTokens.primary),
                    onPressed: () => _selectAnswer(controller.text),
                  )
                : null,
          ),
          onSubmitted: _answered ? null : (value) => _selectAnswer(value),
        ),
        if (exercise.hint != null && !_answered) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  size: 16, color: DesignTokens.warning),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Hint: ${exercise.hint}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: DesignTokens.warning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSentenceBuilder(SessionExercise exercise, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: (exercise.wordBank ?? []).map((word) {
        return ActionChip(
          label: Text(word),
          onPressed:
              _answered ? null : () => _selectAnswer(exercise.correctAnswer),
        );
      }).toList(),
    );
  }

  Widget _buildFeedback(SessionExercise exercise, ThemeData theme) {
    final isCorrect = _isCorrectAnswer();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: isCorrect ? DesignTokens.successLight : DesignTokens.errorLight,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: isCorrect ? DesignTokens.success : DesignTokens.error,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? DesignTokens.success : DesignTokens.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct! 🎉' : 'Not quite',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isCorrect ? DesignTokens.success : DesignTokens.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isCorrect)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DesignTokens.xpGold.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                  child: Text(
                    '+${exercise.points} XP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: DesignTokens.xpGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (exercise.explanation != null) ...[
            const SizedBox(height: 8),
            Text(
              exercise.explanation!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  const TextSpan(
                    text: 'Correct answer: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: exercise.correctAnswer),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isCorrectAnswer() {
    return _selectedAnswer?.trim().toLowerCase() ==
        _currentExercise.correctAnswer.trim().toLowerCase();
  }

  String _exerciseTypeLabel(ExerciseType type) {
    switch (type) {
      case ExerciseType.mcq:
        return 'MULTIPLE CHOICE';
      case ExerciseType.fillBlank:
        return 'FILL IN THE BLANK';
      case ExerciseType.match:
        return 'MATCHING';
      case ExerciseType.translate:
        return 'TRANSLATION';
      case ExerciseType.sentenceBuild:
        return 'SENTENCE BUILDING';
      case ExerciseType.listening:
        return 'LISTENING';
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave session?'),
        content: const Text(
            'Your progress in this session will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

/// Session summary screen showing results after completing a session.
class SessionSummaryScreen extends StatelessWidget {
  final SessionResult result;

  const SessionSummaryScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = (result.accuracy * 100).round();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DesignTokens.spacingLg),
                child: Column(
                  children: [
                    const SizedBox(height: DesignTokens.spacingXl),

                    // Result icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: result.isPerfect
                            ? DesignTokens.successGradient
                            : (accuracy >= 70
                                ? DesignTokens.primaryGradient
                                : DesignTokens.warmGradient),
                        boxShadow: DesignTokens.glowPrimary,
                      ),
                      child: Icon(
                        result.isPerfect
                            ? Icons.emoji_events
                            : (accuracy >= 70
                                ? Icons.check_circle
                                : Icons.refresh),
                        size: 48,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: DesignTokens.spacingLg),
                    Text(
                      result.isPerfect
                          ? 'Perfect! 🎉'
                          : (accuracy >= 70
                              ? 'Great job! 👏'
                              : 'Keep practicing! 💪'),
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: DesignTokens.spacingSm),
                    Text(
                      'Session complete',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: DesignTokens.textSecondaryLight,
                      ),
                    ),

                    const SizedBox(height: DesignTokens.spacingXl),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn(
                          value: '$accuracy%',
                          label: 'Accuracy',
                          color: accuracy >= 70
                              ? DesignTokens.success
                              : DesignTokens.accent,
                        ),
                        _StatColumn(
                          value: '+${result.xpEarned}',
                          label: 'XP Earned',
                          color: DesignTokens.xpGold,
                        ),
                        _StatColumn(
                          value:
                              '${result.correctAnswers}/${result.totalExercises}',
                          label: 'Correct',
                          color: DesignTokens.primary,
                        ),
                      ],
                    ),

                    if (result.streakBonus > 0) ...[
                      const SizedBox(height: DesignTokens.spacingMd),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: DesignTokens.streakOrange.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(DesignTokens.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department,
                                color: DesignTokens.streakOrange, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              'Streak bonus: +${result.streakBonus} XP',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: DesignTokens.streakOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: DesignTokens.spacingXl),

                    // Mistakes section
                    if (result.weakItems.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Items to Review',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacingSm),
                      ...result.exerciseResults
                          .where((r) => !r.isCorrect)
                          .map((r) => Card(
                                child: ListTile(
                                  leading: const Icon(Icons.refresh,
                                      color: DesignTokens.accent),
                                  title: Text(r.correctAnswer),
                                  subtitle: Text(
                                      'You answered: ${r.userAnswer}'),
                                ),
                              )),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom action
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text('Continue',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
