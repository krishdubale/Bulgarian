/// Structured curriculum from A1 to C2.
class Curriculum {
  final String languageId;
  final List<CurriculumLevel> levels;

  const Curriculum({
    required this.languageId,
    required this.levels,
  });

  /// Get the level definition for a CEFR level code.
  CurriculumLevel? getLevel(String levelCode) {
    return levels.where((l) => l.level == levelCode).firstOrNull;
  }

  /// Get all lesson IDs in order.
  List<String> get allLessonIds {
    return levels
        .expand((l) => l.units)
        .expand((u) => u.lessonIds)
        .toList();
  }

  factory Curriculum.fromJson(Map<String, dynamic> json) {
    return Curriculum(
      languageId: json['languageId'] as String? ?? '',
      levels: (json['levels'] as List?)
              ?.map((l) =>
                  CurriculumLevel.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// A CEFR proficiency level with units.
class CurriculumLevel {
  final String level; // A1, A2, B1, etc.
  final String title;
  final List<String> objectives;
  final int vocabTarget;
  final List<String> grammarTopics;
  final List<CurriculumUnit> units;

  const CurriculumLevel({
    required this.level,
    required this.title,
    required this.objectives,
    this.vocabTarget = 200,
    this.grammarTopics = const [],
    required this.units,
  });

  int get totalLessons =>
      units.fold(0, (sum, u) => sum + u.lessonIds.length);

  factory CurriculumLevel.fromJson(Map<String, dynamic> json) {
    return CurriculumLevel(
      level: json['level'] as String? ?? 'A1',
      title: json['title'] as String? ?? '',
      objectives: List<String>.from(json['objectives'] as List? ?? []),
      vocabTarget: (json['vocabTarget'] as num?)?.toInt() ?? 200,
      grammarTopics:
          List<String>.from(json['grammarTopics'] as List? ?? []),
      units: (json['units'] as List?)
              ?.map((u) =>
                  CurriculumUnit.fromJson(u as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// A unit within a level containing lessons.
class CurriculumUnit {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<String> lessonIds;
  final String? reviewLessonId;

  const CurriculumUnit({
    required this.id,
    required this.title,
    this.description = '',
    required this.order,
    required this.lessonIds,
    this.reviewLessonId,
  });

  factory CurriculumUnit.fromJson(Map<String, dynamic> json) {
    return CurriculumUnit(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      lessonIds: List<String>.from(json['lessonIds'] as List? ?? []),
      reviewLessonId: json['reviewLessonId'] as String?,
    );
  }
}
