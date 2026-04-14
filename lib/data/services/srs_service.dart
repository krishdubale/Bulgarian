import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/srs_model.dart';
import '../../core/providers/app_providers.dart';

final srsServiceProvider = Provider<SrsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SrsService(prefs);
});

/// Spaced Repetition Service — manages all SRS cards with SM-2 algorithm.
class SrsService {
  SrsService(this._prefs);

  final SharedPreferences _prefs;

  String _storageKey(String languageId) => 'srs_cards_$languageId';

  /// Load all SRS cards for a language.
  Map<String, SrsCard> loadCards(String languageId) {
    final raw = _prefs.getString(_storageKey(languageId));
    if (raw == null) return {};

    final Map<String, dynamic> decoded = json.decode(raw);
    return decoded.map(
      (key, value) =>
          MapEntry(key, SrsCard.fromJson(value as Map<String, dynamic>)),
    );
  }

  /// Save all SRS cards for a language.
  Future<void> saveCards(String languageId, Map<String, SrsCard> cards) async {
    final encoded = json.encode(
      cards.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _prefs.setString(_storageKey(languageId), encoded);
  }

  /// Get or create a card for an item.
  SrsCard getOrCreateCard(
    String languageId,
    String itemId,
    String itemType,
  ) {
    final cards = loadCards(languageId);
    return cards[itemId] ?? SrsCard.create(itemId: itemId, itemType: itemType);
  }

  /// Process an answer and update the card.
  /// [quality] 0–5 (0 = blackout, 3 = correct with effort, 5 = perfect).
  Future<SrsCard> processAnswer(
    String languageId,
    String itemId,
    String itemType,
    int quality,
  ) async {
    final cards = loadCards(languageId);
    final card = cards[itemId] ??
        SrsCard.create(itemId: itemId, itemType: itemType);

    final updated = card.processAnswer(quality);
    cards[itemId] = updated;
    await saveCards(languageId, cards);
    return updated;
  }

  /// Get all cards that are due for review right now.
  List<SrsCard> getDueCards(String languageId) {
    final cards = loadCards(languageId);
    final due = cards.values.where((c) => c.isDue).toList();
    // Sort by priority (most urgent first).
    due.sort((a, b) => b.reviewPriority.compareTo(a.reviewPriority));
    return due;
  }

  /// Get a limited review queue for daily review.
  List<SrsCard> getReviewQueue(String languageId, {int limit = 15}) {
    return getAdaptiveReviewQueue(languageId, limit: limit);
  }

  /// Get the weakest items (lowest easeFactor, highest error rate).
  List<SrsCard> getWeakItems(String languageId, {int count = 10}) {
    final cards = loadCards(languageId);
    final all = cards.values.toList();
    all.sort((a, b) {
      // Sort by: lowest accuracy first, then lowest easeFactor.
      final accDiff = a.accuracy.compareTo(b.accuracy);
      if (accDiff != 0) return accDiff;
      return a.easeFactor.compareTo(b.easeFactor);
    });
    return all.take(count).toList();
  }

  /// Number of items due for review today.
  int getDailyReviewCount(String languageId) {
    return getDueCards(languageId).length;
  }

  /// High-risk cards that need urgent repair work.
  List<SrsCard> getUrgentCards(String languageId, {int limit = 10}) {
    final cards = loadCards(languageId).values.toList();
    final urgent = cards
        .where((c) => c.failureStreak >= 2 || c.overdueDays >= 3)
        .toList();
    urgent.sort((a, b) => b.reviewPriority.compareTo(a.reviewPriority));
    return urgent.take(limit).toList();
  }

  /// Fragile items with low stability score.
  List<SrsCard> getFragileCards(String languageId, {int limit = 20}) {
    final cards = loadCards(languageId).values.toList();
    final fragile = cards.where((c) => c.stabilityScore < 0.72).toList();
    fragile.sort((a, b) => a.stabilityScore.compareTo(b.stabilityScore));
    return fragile.take(limit).toList();
  }

  /// Interleaved adaptive queue:
  /// 40% mature due + 40% fragile/recent + 20% hotspots.
  List<SrsCard> getAdaptiveReviewQueue(String languageId, {int limit = 15}) {
    if (limit <= 0) return [];

    final now = DateTime.now();
    final cards = loadCards(languageId).values.toList();

    final due = cards
        .where((c) => !c.nextReviewDate.isAfter(now))
        .toList()
      ..sort((a, b) => b.reviewPriority.compareTo(a.reviewPriority));

    final matureDue = due.where((c) => c.stabilityScore >= 0.72).toList();

    final fragile = cards
        .where((c) => c.successRate < 0.7 || c.stabilityScore < 0.5)
        .toList()
      ..sort((a, b) => b.reviewPriority.compareTo(a.reviewPriority));
    if (fragile.length > limit * 2) {
      fragile.removeRange(limit * 2, fragile.length);
    }

    final hotspots = cards
        .where((c) => c.reviewPriority > 0)
        .toList()
      ..sort((a, b) => b.reviewPriority.compareTo(a.reviewPriority));
    if (hotspots.length > limit * 2) {
      hotspots.removeRange(limit * 2, hotspots.length);
    }

    final matureTarget = (limit * 0.4).round();
    final fragileTarget = (limit * 0.4).round();
    final hotspotTarget = limit - matureTarget - fragileTarget;

    final queue = <SrsCard>[];
    final seen = <String>{};

    void takeCards(List<SrsCard> source, int count) {
      var remaining = count;
      for (final card in source) {
        if (queue.length >= limit || remaining <= 0) break;
        if (seen.add(card.itemId)) {
          queue.add(card);
          remaining--;
        }
      }
    }

    takeCards(matureDue, matureTarget);
    takeCards(fragile, fragileTarget);
    takeCards(hotspots, hotspotTarget);

    if (queue.length < limit) {
      takeCards(due, limit - queue.length);
    }
    if (queue.length < limit) {
      final all = List<SrsCard>.from(cards)
        ..sort((a, b) => b.reviewPriority.compareTo(a.reviewPriority));
      takeCards(all, limit - queue.length);
    }

    return queue.take(limit).toList();
  }

  /// Get items that haven't been seen in [days] days.
  List<SrsCard> getStaleItems(String languageId, {int days = 7}) {
    final cards = loadCards(languageId);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return cards.values
        .where((c) => c.lastReviewDate.isBefore(cutoff))
        .toList();
  }

  /// Batch process: mark a correct/incorrect answer quickly.
  Future<SrsCard> markCorrect(
    String languageId,
    String itemId,
    String itemType,
  ) {
    return processAnswer(languageId, itemId, itemType, 4);
  }

  Future<SrsCard> markIncorrect(
    String languageId,
    String itemId,
    String itemType,
  ) {
    return processAnswer(languageId, itemId, itemType, 1);
  }
}
