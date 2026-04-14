class LessonModel {
  final String id;
  final String title;
  final String description;
  final String level;
  final String category;
  final int xpReward;
  final bool isCompleted;
  final List<String> wordIds;

  const LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.category,
    required this.xpReward,
    this.isCompleted = false,
    this.wordIds = const [],
  });

  LessonModel copyWith({
    String? id,
    String? title,
    String? description,
    String? level,
    String? category,
    int? xpReward,
    bool? isCompleted,
    List<String>? wordIds,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      category: category ?? this.category,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      wordIds: wordIds ?? this.wordIds,
    );
  }
}
