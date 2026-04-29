import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';
import '../models/food_item_model.dart';

class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Add a new review for a food item
  Future<Review> addReview(Review review) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final reviewData = review.toJson()
        ..['user_id'] = user.id;

      final response = await _supabase
          .from('reviews')
          .insert(reviewData)
          .select()
          .single();

      final addedReview = Review.fromJson(response);

      // Update the food item's review score to the average of all its reviews
      await _updateFoodItemReviewScore(review.foodItemId);

      return addedReview;
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // Get all reviews for a specific food item
  Future<List<Review>> getReviewsForFoodItem(String foodItemId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('food_item_id', foodItemId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Review.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  // Update the review score of a food item to the average of its reviews
  Future<void> _updateFoodItemReviewScore(String foodItemId) async {
    try {
      final reviews = await getReviewsForFoodItem(foodItemId);
      if (reviews.isEmpty) {
        // No reviews, set review score to null
        await _supabase
            .from('food_items')
            .update({'review_score': null})
            .eq('id', foodItemId);
      } else {
        final total = reviews.fold(0, (sum, review) => sum + review.rating);
        final average = total / reviews.length;
        await _supabase
            .from('food_items')
            .update({'review_score': average})
            .eq('id', foodItemId);
      }
    } catch (e) {
      throw Exception('Failed to update food item review score: $e');
    }
  }
}