class Exercise {
  final String id;
  final String lessonId;
  final String type;
  final String prompt;
  final String answer;

  const Exercise({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.prompt,
    required this.answer,
  });

  Exercise copyWith({
    String? id,
    String? lessonId,
    String? type,
    String? prompt,
    String? answer,
  }) {
    return Exercise(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      type: type ?? this.type,
      prompt: prompt ?? this.prompt,
      answer: answer ?? this.answer,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'type': type,
        'prompt': prompt,
        'answer': answer,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      lessonId: json['lessonId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );
  }
}

