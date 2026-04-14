class ReviewItem {
  final String id;
  final String skillId;
  final String targetId;
  final DateTime dueAt;
  final int intervalDays;
  final int repetitions;

  const ReviewItem({
    required this.id,
    required this.skillId,
    required this.targetId,
    required this.dueAt,
    this.intervalDays = 0,
    this.repetitions = 0,
  });

  ReviewItem copyWith({
    String? id,
    String? skillId,
    String? targetId,
    DateTime? dueAt,
    int? intervalDays,
    int? repetitions,
  }) {
    return ReviewItem(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      targetId: targetId ?? this.targetId,
      dueAt: dueAt ?? this.dueAt,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'skillId': skillId,
        'targetId': targetId,
        'dueAt': dueAt.toIso8601String(),
        'intervalDays': intervalDays,
        'repetitions': repetitions,
      };

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: json['id'] as String? ?? '',
      skillId: json['skillId'] as String? ?? '',
      targetId: json['targetId'] as String? ?? '',
      dueAt: json['dueAt'] != null
          ? DateTime.parse(json['dueAt'] as String)
          : DateTime.now(),
      intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 0,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
    );
  }
}

