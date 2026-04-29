import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/review_service.dart';

// Provider for the review service
final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

// StateNotifier for managing reviews for a specific food item
class ReviewsNotifier extends StateNotifier<AsyncValue<List<Review>>> {
  final ReviewService _reviewService;
  final String _foodItemId;

  ReviewsNotifier(this._reviewService, this._foodItemId)
      : super(const AsyncValue.loading()) {
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    state = const AsyncValue.loading();
    try {
      final reviews = await _reviewService.getReviewsForFoodItem(_foodItemId);
      state = AsyncValue.data(reviews);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addReview(Review review) async {
    try {
      await _reviewService.addReview(review);
      await _loadReviews(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Provider family that takes a foodItemId and returns a ReviewsNotifier
final reviewsProvider = StateNotifierProvider.family
    <ReviewsNotifier, AsyncValue<List<Review>>, String>((ref, foodItemId) {
  return ReviewsNotifier(ref.read(reviewServiceProvider), foodItemId);
});