class SimpleUser {
  final String id;
  final String email;
  final int xp;
  final int streak;

  SimpleUser({
    required this.id,
    required this.email,
    required this.xp,
    required this.streak,
  });
}

class SimpleWord {
  final String id;
  final String text;
  final String translation;
  final String exampleSentence;

  SimpleWord({
    required this.id,
    required this.text,
    required this.translation,
    required this.exampleSentence,
  });
}

class SimpleLesson {
  final String id;
  final String title;
  final List<SimpleWord> words;
  final List<String> sentences;

  SimpleLesson({
    required this.id,
    required this.title,
    required this.words,
    required this.sentences,
  });
}

class SimpleProgress {
  final String userId;
  final List<String> completedLessons;
  final List<String> learnedWords;

  SimpleProgress({
    required this.userId,
    required this.completedLessons,
    required this.learnedWords,
  });
}
