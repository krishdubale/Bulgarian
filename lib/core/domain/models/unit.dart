class UnitModel {
  final String id;
  final String courseId;
  final int order;
  final String title;
  final List<String> lessonIds;

  const UnitModel({
    required this.id,
    required this.courseId,
    required this.order,
    required this.title,
    this.lessonIds = const [],
  });

  UnitModel copyWith({
    String? id,
    String? courseId,
    int? order,
    String? title,
    List<String>? lessonIds,
  }) {
    return UnitModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      order: order ?? this.order,
      title: title ?? this.title,
      lessonIds: lessonIds ?? this.lessonIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'order': order,
        'title': title,
        'lessonIds': lessonIds,
      };

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      lessonIds: List<String>.from(json['lessonIds'] as List? ?? const []),
    );
  }
}

