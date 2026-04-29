import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_model.dart';

class RestaurantService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all restaurants for the current user
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('restaurants')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load restaurants: $e');
    }
  }

  // Get a restaurant by ID (for the current user)
  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('restaurants')
          .select()
          .eq('id', id)
          .eq('user_id', user.id)
          .single();

      return response != null ? Restaurant.fromJson(response) : null;
    } catch (e) {
      // If the restaurant is not found or an error occurs, return null
      return null;
    }
  }

  // Add a new restaurant
  Future<Restaurant> addRestaurant(Restaurant restaurant) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final restaurantData = restaurant.toJson()
        ..['user_id'] = user.id;

      final response = await _supabase
          .from('restaurants')
          .insert(restaurantData)
          .select()
          .single();

      return Restaurant.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add restaurant: $e');
    }
  }

  // Update an existing restaurant
  Future<Restaurant> updateRestaurant(Restaurant restaurant) async {
    try {
      if (restaurant.id == null) throw Exception('Restaurant ID is required');

      final response = await _supabase
          .from('restaurants')
          .update(restaurant.toJson())
          .eq('id', restaurant.id)
          .select()
          .single();

      return Restaurant.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update restaurant: $e');
    }
  }

  // Delete a restaurant
  Future<void> deleteRestaurant(String id) async {
    try {
      await _supabase.from('restaurants').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete restaurant: $e');
    }
  }
}