import '../../core/constants/bulgarian_data.dart';
import '../models/lesson_model.dart';

class LessonRepository {
  static List<LessonModel> getAllLessons() {
    return [
      const LessonModel(
        id: 'alphabet_a1',
        title: 'The Cyrillic Alphabet',
        description: 'Learn all 30 Bulgarian Cyrillic letters',
        level: 'A1',
        category: 'Alphabet',
        xpReward: 20,
      ),
      const LessonModel(
        id: 'greetings_a1',
        title: 'Greetings & Farewells',
        description: 'Essential phrases for meeting people',
        level: 'A1',
        category: 'Vocabulary',
        xpReward: 15,
      ),
      const LessonModel(
        id: 'numbers_a1',
        title: 'Numbers 1–10',
        description: 'Count in Bulgarian',
        level: 'A1',
        category: 'Vocabulary',
        xpReward: 15,
      ),
      const LessonModel(
        id: 'grammar_sentence_a1',
        title: 'Basic Sentence Structure',
        description: 'SVO order and definite articles',
        level: 'A1',
        category: 'Grammar',
        xpReward: 20,
      ),
      const LessonModel(
        id: 'family_a1',
        title: 'Family Members',
        description: 'Vocabulary for family relationships',
        level: 'A1',
        category: 'Vocabulary',
        xpReward: 15,
      ),
      const LessonModel(
        id: 'grammar_noun_gender_a1',
        title: 'Noun Gender',
        description: 'Masculine, feminine and neuter nouns',
        level: 'A1',
        category: 'Grammar',
        xpReward: 20,
      ),
    ];
  }

  static List<BulgarianWord> getWordsByCategory(String category) {
    return BulgarianData.vocabulary
        .where((w) => w.category == category)
        .toList();
  }
}
