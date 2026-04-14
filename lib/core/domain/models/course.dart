class Course {
  final String id;
  final String languageCode;
  final String cefrLevel;
  final List<String> unitIds;

  const Course({
    required this.id,
    required this.languageCode,
    required this.cefrLevel,
    this.unitIds = const [],
  });

  Course copyWith({
    String? id,
    String? languageCode,
    String? cefrLevel,
    List<String>? unitIds,
  }) {
    return Course(
      id: id ?? this.id,
      languageCode: languageCode ?? this.languageCode,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      unitIds: unitIds ?? this.unitIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'languageCode': languageCode,
        'cefrLevel': cefrLevel,
        'unitIds': unitIds,
      };

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String? ?? '',
      languageCode: json['languageCode'] as String? ?? '',
      cefrLevel: json['cefrLevel'] as String? ?? '',
      unitIds: List<String>.from(json['unitIds'] as List? ?? const []),
    );
  }
}

