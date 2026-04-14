class ExerciseModel {
  final String id;
  final String type; // 'multiple_choice', 'fill_blank', 'translation'
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String level;

  const ExerciseModel({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    required this.level,
  });
}
