class Word {
  final String id;
  final String value;
  final String meaning;
  final List<String> tags;

  const Word({
    required this.id,
    required this.value,
    required this.meaning,
    this.tags = const [],
  });

  Word copyWith({
    String? id,
    String? value,
    String? meaning,
    List<String>? tags,
  }) {
    return Word(
      id: id ?? this.id,
      value: value ?? this.value,
      meaning: meaning ?? this.meaning,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value,
        'meaning': meaning,
        'tags': tags,
      };

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String? ?? '',
      value: json['value'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      tags: List<String>.from(json['tags'] as List? ?? const []),
    );
  }
}

