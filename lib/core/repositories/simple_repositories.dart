import '../models/simple_models.dart';

class UserRepository {
  SimpleUser? _currentUser;

  UserRepository() {
    // Mock user for now
    _currentUser = SimpleUser(
      id: 'local_user_1',
      email: 'test@example.com',
      xp: 150,
      streak: 3,
    );
  }

  Future<SimpleUser?> getCurrentUser() async {
    return _currentUser;
  }
}

class LessonRepository {
  final List<SimpleLesson> _mockLessons = [
    SimpleLesson(
      id: 'lesson_1',
      title: 'Basics 1',
      words: [
        SimpleWord(id: 'w1', text: 'здравей', translation: 'hello', exampleSentence: 'Здравей, как си?'),
        SimpleWord(id: 'w2', text: 'да', translation: 'yes', exampleSentence: 'Да, разбирам.'),
        SimpleWord(id: 'w3', text: 'не', translation: 'no', exampleSentence: 'Не, благодаря.'),
      ],
      sentences: [
        'Здравей! Да, благодаря.',
        'Не, не разбирам.'
      ],
    ),
  ];

  Future<List<SimpleLesson>> getLessons() async {
    return _mockLessons;
  }

  Future<SimpleLesson?> getLessonById(String id) async {
    try {
      return _mockLessons.firstWhere((lesson) => lesson.id == id);
    } catch (_) {
      return null;
    }
  }
}

class ProgressRepository {
  SimpleProgress? _currentProgress;

  ProgressRepository() {
    _currentProgress = SimpleProgress(
      userId: 'local_user_1',
      completedLessons: [],
      learnedWords: [],
    );
  }

  Future<SimpleProgress?> getProgress() async {
    return _currentProgress;
  }

  Future<void> saveProgress(SimpleProgress progress) async {
    _currentProgress = progress;
  }
}
