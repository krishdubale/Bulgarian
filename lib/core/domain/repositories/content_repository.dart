import '../models/models.dart';

abstract class ContentRepository {
  Future<List<Course>> getCourses({required String languageCode});
  Future<List<UnitModel>> getUnits({required String courseId});
  Future<List<LessonDomainModel>> getLessons({required String unitId});
  Future<List<Exercise>> getExercises({required String lessonId});
  Future<List<Word>> getWords({required String lessonId});
}

