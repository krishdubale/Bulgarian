import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/simple_models.dart';
import '../../../core/repositories/simple_repositories.dart';

class BasicHomeScreen extends StatefulWidget {
  const BasicHomeScreen({Key? key}) : super(key: key);

  @override
  _BasicHomeScreenState createState() => _BasicHomeScreenState();
}

class _BasicHomeScreenState extends State<BasicHomeScreen> {
  final LessonRepository _lessonRepo = LessonRepository();
  final ProgressRepository _progressRepo = ProgressRepository();
  final UserRepository _userRepo = UserRepository();
  
  SimpleLesson? _nextLesson;
  SimpleUser? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final lessons = await _lessonRepo.getLessons();
    final user = await _userRepo.getCurrentUser();
    if (mounted) {
      setState(() {
        _nextLesson = lessons.isNotEmpty ? lessons.first : null;
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: _nextLesson == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome! Streak: ${_user?.streak ?? 0}'),
                  const SizedBox(height: 20),
                  Text('Up next: ${_nextLesson!.title}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BasicExerciseScreen(lesson: _nextLesson!),
                        ),
                      );
                    },
                    child: const Text('Start Lesson'),
                  ),
                ],
              ),
      ),
    );
  }
}

class BasicExerciseScreen extends StatefulWidget {
  final SimpleLesson lesson;
  const BasicExerciseScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  _BasicExerciseScreenState createState() => _BasicExerciseScreenState();
}

class _BasicExerciseScreenState extends State<BasicExerciseScreen> {
  int _currentIndex = 0;
  bool _showingWords = true;
  String? _message;

  @override
  void initState() {
    super.initState();
  }

  void _nextWord() {
    setState(() {
      if (_currentIndex < widget.lesson.words.length - 1) {
        _currentIndex++;
      } else {
        _showingWords = false;
        _currentIndex = 0;
      }
    });
  }

  void _checkAnswer(bool correct) {
    if (correct) {
      if (_currentIndex < widget.lesson.words.length - 1) {
        setState(() {
          _currentIndex++;
          _message = 'Correct!';
        });
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BasicResultScreen(lesson: widget.lesson),
          ),
        );
      }
    } else {
      setState(() {
        _message = 'Incorrect, try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showingWords) {
      final word = widget.lesson.words[_currentIndex];
      return Scaffold(
        appBar: AppBar(title: const Text('Vocabulary')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(word.text, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 10),
              Text(word.translation, style: const TextStyle(fontSize: 24, color: Colors.grey)),
              const SizedBox(height: 10),
              Text(word.exampleSentence, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _nextWord,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      );
    } else {
      final targetWord = widget.lesson.words[_currentIndex];
      return Scaffold(
        appBar: AppBar(title: const Text('Exercise')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Translate: ${targetWord.text}', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children: widget.lesson.words.map((w) {
                  return ElevatedButton(
                    onPressed: () => _checkAnswer(w.id == targetWord.id),
                    child: Text(w.translation),
                  );
                }).toList(),
              ),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(_message!, style: const TextStyle(color: Colors.blue)),
              ],
            ],
          ),
        ),
      );
    }
  }
}

class BasicResultScreen extends StatelessWidget {
  final SimpleLesson lesson;
  const BasicResultScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Lesson Complete!', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Return to home
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
