class CourseBlueprint {
  final String version;
  final String name;
  final BlueprintScope scope;
  final List<BlueprintUnit> units;
  final Map<String, dynamic> lessonTemplate;
  final Map<String, dynamic> vocabularySystem;
  final Map<String, dynamic> grammarProgression;
  final Map<String, dynamic> sentenceDesign;
  final Map<String, dynamic> multiLanguageDesign;
  final List<BlueprintRule> strictScalingRules;

  const CourseBlueprint({
    required this.version,
    required this.name,
    required this.scope,
    required this.units,
    required this.lessonTemplate,
    required this.vocabularySystem,
    required this.grammarProgression,
    required this.sentenceDesign,
    required this.multiLanguageDesign,
    required this.strictScalingRules,
  });

  int get totalLessons => scope.totalLessons;

  List<BlueprintUnit> unitsForLevel(String level) {
    return units.where((u) => u.level == level).toList();
  }

  List<String> lessonIdsForUnit(String unitId) {
    return List<String>.generate(
      scope.lessonsPerUnit,
      (index) => '${unitId}_l${index + 1}',
    );
  }

  factory CourseBlueprint.fromJson(Map<String, dynamic> json) {
    return CourseBlueprint(
      version: json['version'] as String? ?? '1.0',
      name: json['name'] as String? ?? 'Course Blueprint',
      scope: BlueprintScope.fromJson(json['scope'] as Map<String, dynamic>? ?? {}),
      units: (json['units'] as List?)
              ?.map((u) => BlueprintUnit.fromJson(u as Map<String, dynamic>))
              .toList() ??
          const [],
      lessonTemplate:
          Map<String, dynamic>.from(json['lessonTemplate'] as Map? ?? {}),
      vocabularySystem:
          Map<String, dynamic>.from(json['vocabularySystem'] as Map? ?? {}),
      grammarProgression:
          Map<String, dynamic>.from(json['grammarProgression'] as Map? ?? {}),
      sentenceDesign:
          Map<String, dynamic>.from(json['sentenceDesign'] as Map? ?? {}),
      multiLanguageDesign:
          Map<String, dynamic>.from(json['multiLanguageDesign'] as Map? ?? {}),
      strictScalingRules: (json['strictScalingRules'] as List?)
              ?.map((r) => BlueprintRule.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class BlueprintScope {
  final List<String> levels;
  final int unitsTotal;
  final int unitsPerLevel;
  final int lessonsPerUnit;
  final int totalLessons;

  const BlueprintScope({
    required this.levels,
    required this.unitsTotal,
    required this.unitsPerLevel,
    required this.lessonsPerUnit,
    required this.totalLessons,
  });

  factory BlueprintScope.fromJson(Map<String, dynamic> json) {
    return BlueprintScope(
      levels: List<String>.from(json['levels'] as List? ?? const ['A1', 'A2', 'B1']),
      unitsTotal: (json['unitsTotal'] as num?)?.toInt() ?? 36,
      unitsPerLevel: (json['unitsPerLevel'] as num?)?.toInt() ?? 12,
      lessonsPerUnit: (json['lessonsPerUnit'] as num?)?.toInt() ?? 8,
      totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 288,
    );
  }
}

class BlueprintUnit {
  final String id;
  final String level;
  final String title;
  final List<String> grammarFocus;
  final List<String> vocabFocus;

  const BlueprintUnit({
    required this.id,
    required this.level,
    required this.title,
    required this.grammarFocus,
    required this.vocabFocus,
  });

  factory BlueprintUnit.fromJson(Map<String, dynamic> json) {
    return BlueprintUnit(
      id: json['id'] as String? ?? '',
      level: json['level'] as String? ?? 'A1',
      title: json['title'] as String? ?? '',
      grammarFocus: List<String>.from(json['grammarFocus'] as List? ?? const []),
      vocabFocus: List<String>.from(json['vocabFocus'] as List? ?? const []),
    );
  }
}

class BlueprintRule {
  final int id;
  final String rule;
  final String value;

  const BlueprintRule({
    required this.id,
    required this.rule,
    required this.value,
  });

  factory BlueprintRule.fromJson(Map<String, dynamic> json) {
    return BlueprintRule(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rule: json['rule'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }
}
