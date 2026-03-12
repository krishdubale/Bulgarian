class WordModel {
  final String id;
  final String bulgarian;
  final String transliteration;
  final String english;
  final String category;
  final String? exampleBulgarian;
  final String? exampleEnglish;
  final bool isLearned;
  final int reviewCount;
  final DateTime? nextReviewDate;

  const WordModel({
    required this.id,
    required this.bulgarian,
    required this.transliteration,
    required this.english,
    required this.category,
    this.exampleBulgarian,
    this.exampleEnglish,
    this.isLearned = false,
    this.reviewCount = 0,
    this.nextReviewDate,
  });

  WordModel copyWith({
    String? id,
    String? bulgarian,
    String? transliteration,
    String? english,
    String? category,
    String? exampleBulgarian,
    String? exampleEnglish,
    bool? isLearned,
    int? reviewCount,
    DateTime? nextReviewDate,
  }) {
    return WordModel(
      id: id ?? this.id,
      bulgarian: bulgarian ?? this.bulgarian,
      transliteration: transliteration ?? this.transliteration,
      english: english ?? this.english,
      category: category ?? this.category,
      exampleBulgarian: exampleBulgarian ?? this.exampleBulgarian,
      exampleEnglish: exampleEnglish ?? this.exampleEnglish,
      isLearned: isLearned ?? this.isLearned,
      reviewCount: reviewCount ?? this.reviewCount,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }
}
