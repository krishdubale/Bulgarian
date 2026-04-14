import '../models/models.dart';

abstract class ProgressRepository {
  Future<Progress?> loadProgress({
    required String userId,
    required String languageId,
  });

  Future<void> saveProgress(Progress progress);
  Future<Map<String, Skill>> loadSkillStates({
    required String userId,
    required String languageId,
  });
  Future<void> saveSkillStates({
    required String userId,
    required String languageId,
    required Map<String, Skill> skills,
  });
}

