import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_item_model.dart';

class FoodItemService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all food items for a specific restaurant (for the current user)
  Future<List<FoodItem>> getFoodItemsByRestaurant(String restaurantId, {String sortBy = 'created_at', bool ascending = false}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final query = _supabase
          .from('food_items')
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('user_id', user.id);

      // Apply sorting based on sortBy parameter
      switch (sortBy) {
        case 'price':
          return (await query.order('price', ascending: ascending)).map((json) => FoodItem.fromJson(json)).toList();
        case 'review_score':
          return (await query.order('review_score', ascending: ascending)).map((json) => FoodItem.fromJson(json)).toList();
        case 'name':
          return (await query.order('name', ascending: ascending)).map((json) => FoodItem.fromJson(json)).toList();
        case 'created_at':
        default:
          return (await query.order('created_at', ascending: ascending)).map((json) => FoodItem.fromJson(json)).toList();
      }
    } catch (e) {
      throw Exception('Failed to load food items: $e');
    }
  }

  // Add a new food item
  Future<FoodItem> addFoodItem(FoodItem foodItem) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final foodItemData = foodItem.toJson()
        ..['user_id'] = user.id;

      final response = await _supabase
          .from('food_items')
          .insert(foodItemData)
          .select()
          .single();

      return FoodItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add food item: $e');
    }
  }

  // Update an existing food item
  Future<FoodItem> updateFoodItem(FoodItem foodItem) async {
    try {
      if (foodItem.id == null) throw Exception('Food item ID is required');

      final response = await _supabase
          .from('food_items')
          .update(foodItem.toJson())
          .eq('id', foodItem.id)
          .select()
          .single();

      return FoodItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update food item: $e');
    }
  }

  // Delete a food item
  Future<void> deleteFoodItem(String id) async {
    try {
      await _supabase.from('food_items').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete food item: $e');
    }
  }

  // Get all food items for the current user (for explore tab)
  Future<List<FoodItem>> getAllFoodItems({String sortBy = 'created_at', bool ascending = false}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final query = _supabase
          .from('food_items')
          .select()
          .eq('user_id', user.id);

      // Apply sorting based on sortBy parameter
      switch (sortBy) {
        case 'price':
          return (await query.order('price', ascending: ascending)).map((json) => FoodItem.fromJson(json)).toList();
        case 'review_score':
          return (await query.order('review_score', ascending: ascending)).map((json) => FoodItem.fromJson(json)).toList();
        case 'name':
          return (await query.order('name', ascending: ascending)).map((json) => FoodItem.fromJson(json)).toList();
        case 'created_at':
        default:
          return (await query.order('created_at', ascending: ascending)).map((json) => FoodItem.fromJson(json)).toList();
      }
    } catch (e) {
      throw Exception('Failed to load food items: $e');
    }
  }
}