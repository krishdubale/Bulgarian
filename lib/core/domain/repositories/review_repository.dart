import '../models/models.dart';

abstract class ReviewRepository {
  Future<List<ReviewItem>> getDueItems({
    required String userId,
    required String languageId,
    int limit = 50,
  });

  Future<void> upsertReviewItems({
    required String userId,
    required String languageId,
    required List<ReviewItem> items,
  });
}

