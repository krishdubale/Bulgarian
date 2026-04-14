class MistakeEvent {
  final String id;
  final String userId;
  final String lessonId;
  final String skillId;
  final String errorType;
  final DateTime createdAt;

  const MistakeEvent({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.skillId,
    required this.errorType,
    required this.createdAt,
  });

  MistakeEvent copyWith({
    String? id,
    String? userId,
    String? lessonId,
    String? skillId,
    String? errorType,
    DateTime? createdAt,
  }) {
    return MistakeEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      skillId: skillId ?? this.skillId,
      errorType: errorType ?? this.errorType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'lessonId': lessonId,
        'skillId': skillId,
        'errorType': errorType,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MistakeEvent.fromJson(Map<String, dynamic> json) {
    return MistakeEvent(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      lessonId: json['lessonId'] as String? ?? '',
      skillId: json['skillId'] as String? ?? '',
      errorType: json['errorType'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

