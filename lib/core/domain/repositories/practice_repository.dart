import '../models/models.dart';

abstract class PracticeRepository {
  Future<List<Exercise>> createPracticeSet({
    required String userId,
    required String languageId,
    required int itemCount,
  });

  Future<void> logMistake(MistakeEvent event);
  Future<List<MistakeEvent>> getRecentMistakes({
    required String userId,
    int limit = 20,
  });
}

