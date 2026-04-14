class Skill {
  final String id;
  final String name;
  final int mastery; // 0..5
  final DateTime? updatedAt;

  const Skill({
    required this.id,
    required this.name,
    this.mastery = 0,
    this.updatedAt,
  });

  Skill copyWith({
    String? id,
    String? name,
    int? mastery,
    DateTime? updatedAt,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      mastery: mastery ?? this.mastery,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mastery': mastery,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mastery: (json['mastery'] as num?)?.toInt() ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

