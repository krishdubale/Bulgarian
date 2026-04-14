class LessonDomainModel {
  final String id;
  final String unitId;
  final int order;
  final String title;
  final List<String> skillIds;

  const LessonDomainModel({
    required this.id,
    required this.unitId,
    required this.order,
    required this.title,
    this.skillIds = const [],
  });

  LessonDomainModel copyWith({
    String? id,
    String? unitId,
    int? order,
    String? title,
    List<String>? skillIds,
  }) {
    return LessonDomainModel(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      order: order ?? this.order,
      title: title ?? this.title,
      skillIds: skillIds ?? this.skillIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unitId': unitId,
        'order': order,
        'title': title,
        'skillIds': skillIds,
      };

  factory LessonDomainModel.fromJson(Map<String, dynamic> json) {
    return LessonDomainModel(
      id: json['id'] as String? ?? '',
      unitId: json['unitId'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      skillIds: List<String>.from(json['skillIds'] as List? ?? const []),
    );
  }
}

