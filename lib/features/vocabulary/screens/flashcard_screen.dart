import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/content_loader.dart';
import '../../../core/services/language_manager.dart';
import '../../../core/repositories/progress_repository.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final String category;
  const FlashcardScreen({super.key, required this.category});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen>
    with TickerProviderStateMixin {
  List<ContentWord> _words = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _learned = 0;
  bool _finished = false;
  bool _loaded = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.5)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_flipController);
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_flipController.isAnimating) return;
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _markLearned() {
    final word = _words[_currentIndex];

    setState(() => _learned++);

    ref.read(userProgressProvider.notifier).markNewWordLearned(
          word.target,
          category: widget.category,
        );

    _next();
  }

  void _next() {
    if (_currentIndex + 1 >= _words.length) {
      setState(() => _finished = true);
      final lessonId = 'flashcard_${widget.category}';
      ref.read(userProgressProvider.notifier).markLessonComplete(lessonId);
      return;
    }
    _flipController.reset();
    setState(() {
      _currentIndex++;
      _isFlipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langId = ref.watch(selectedLanguageProvider).id;
    final vocabAsync = ref.watch(vocabularyProvider(langId));

    return vocabAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(widget.category)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(widget.category)),
        body: Center(child: Text('Error loading vocabulary: $e')),
      ),
      data: (categories) {
        if (!_loaded) {
          _words = categories
              .expand((c) => c.words)
              .where((w) => w.category == widget.category)
              .toList();
          _loaded = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.category),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${_currentIndex + 1} / ${_words.length}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          body: _finished ? _buildFinished() : _buildCard(theme),
        );
      },
    );
  }

  Widget _buildCard(ThemeData theme) {
    if (_words.isEmpty) {
      return const Center(child: Text('No words in this category'));
    }

    final word = _words[_currentIndex];
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentIndex + 1) / _words.length,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          color: theme.colorScheme.primary,
          minHeight: 4,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _flip,
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, child) {
                        final isShowingBack = _flipAnimation.value >= 0.5;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(
                                3.14159 * _flipAnimation.value),
                          child: isShowingBack
                              ? _CardBack(word: word)
                              : _CardFront(word: word),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap card to flip',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.arrow_forward,
                            color: Colors.grey),
                        label: const Text('Skip',
                            style: TextStyle(color: Colors.grey)),
                        onPressed: _next,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Got it!'),
                        onPressed: _markLearned,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinished() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 72, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Session Complete!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_learned / ${_words.length} words learned',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Practice Again'),
              onPressed: () {
                _flipController.reset();
                setState(() {
                  _currentIndex = 0;
                  _isFlipped = false;
                  _learned = 0;
                  _finished = false;
                  _words.shuffle();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final ContentWord word;
  const _CardFront({required this.word});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.colorScheme.primary,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                word.target,
                style: const TextStyle(
                  fontSize: 42,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                word.transliteration,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final ContentWord word;
  const _CardBack({required this.word});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(3.14159),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  word.english,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (word.exampleTarget != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    ),
                    child: Column(
                      children: [
                        Text(
                          word.exampleTarget!,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          word.exampleEnglish ?? '',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('🇬🇧 English',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
