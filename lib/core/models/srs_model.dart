import 'dart:math';

/// Spaced Repetition System card model.
/// Tracks per-item retention using the SM-2 algorithm.
class SrsCard {
  final String itemId;
  final String itemType; // 'word', 'grammar', 'phrase'
  final double easeFactor; // starts at 2.5, min 1.3
  final int interval; // days until next review
  final int repetitionCount; // successful reviews in a row
  final DateTime nextReviewDate;
  final DateTime lastReviewDate;
  final int totalReviews;
  final int correctCount;
  final int incorrectCount;

  const SrsCard({
    required this.itemId,
    required this.itemType,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitionCount = 0,
    required this.nextReviewDate,
    required this.lastReviewDate,
    this.totalReviews = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
  });

  factory SrsCard.create({
    required String itemId,
    required String itemType,
  }) {
    final now = DateTime.now();
    return SrsCard(
      itemId: itemId,
      itemType: itemType,
      nextReviewDate: now,
      lastReviewDate: now,
    );
  }

  /// Whether this card is due for review.
  bool get isDue => DateTime.now().isAfter(nextReviewDate) ||
      DateTime.now().isAtSameMomentAs(nextReviewDate);

  /// Days overdue (0 if not overdue).
  int get overdueDays {
    final diff = DateTime.now().difference(nextReviewDate).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Accuracy percentage (0–100).
  double get accuracy =>
      totalReviews > 0 ? (correctCount / totalReviews) * 100 : 0;

  /// Priority score for review queue — higher = more urgent.
  double get reviewPriority {
    return (overdueDays * 2.0) +
        (incorrectCount * 1.5) -
        (easeFactor * 0.5);
  }

  /// Process an answer using SM-2 algorithm.
  /// [quality] is 0–5 where:
  ///   0 = total blackout
  ///   1 = wrong, recognized after seeing answer
  ///   2 = wrong, but felt close
  ///   3 = correct with difficulty
  ///   4 = correct with hesitation
  ///   5 = perfect recall
  SrsCard processAnswer(int quality) {
    assert(quality >= 0 && quality <= 5);

    int newInterval;
    int newRepetition;
    double newEaseFactor;

    if (quality >= 3) {
      // Correct response
      if (repetitionCount == 0) {
        newInterval = 1;
      } else if (repetitionCount == 1) {
        newInterval = 6;
      } else {
        newInterval = (interval * easeFactor).round();
      }
      newRepetition = repetitionCount + 1;
    } else {
      // Incorrect — reset
      newRepetition = 0;
      newInterval = 1;
    }

    // Update ease factor
    newEaseFactor = easeFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    newEaseFactor = max(1.3, newEaseFactor);

    final now = DateTime.now();
    return SrsCard(
      itemId: itemId,
      itemType: itemType,
      easeFactor: newEaseFactor,
      interval: newInterval,
      repetitionCount: newRepetition,
      nextReviewDate: now.add(Duration(days: newInterval)),
      lastReviewDate: now,
      totalReviews: totalReviews + 1,
      correctCount: quality >= 3 ? correctCount + 1 : correctCount,
      incorrectCount: quality < 3 ? incorrectCount + 1 : incorrectCount,
    );
  }

  SrsCard copyWith({
    String? itemId,
    String? itemType,
    double? easeFactor,
    int? interval,
    int? repetitionCount,
    DateTime? nextReviewDate,
    DateTime? lastReviewDate,
    int? totalReviews,
    int? correctCount,
    int? incorrectCount,
  }) {
    return SrsCard(
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      totalReviews: totalReviews ?? this.totalReviews,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemType': itemType,
        'easeFactor': easeFactor,
        'interval': interval,
        'repetitionCount': repetitionCount,
        'nextReviewDate': nextReviewDate.toIso8601String(),
        'lastReviewDate': lastReviewDate.toIso8601String(),
        'totalReviews': totalReviews,
        'correctCount': correctCount,
        'incorrectCount': incorrectCount,
      };

  factory SrsCard.fromJson(Map<String, dynamic> json) {
    return SrsCard(
      itemId: json['itemId'] as String,
      itemType: json['itemType'] as String? ?? 'word',
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: (json['interval'] as num?)?.toInt() ?? 0,
      repetitionCount: (json['repetitionCount'] as num?)?.toInt() ?? 0,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'] as String)
          : DateTime.now(),
      lastReviewDate: json['lastReviewDate'] != null
          ? DateTime.parse(json['lastReviewDate'] as String)
          : DateTime.now(),
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      incorrectCount: (json['incorrectCount'] as num?)?.toInt() ?? 0,
    );
  }
}
