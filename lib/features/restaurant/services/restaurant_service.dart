import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_model.dart';

class RestaurantService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all restaurants from local JSON asset
  Future<List<Restaurant>> getRestaurantsFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/restaurants.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final restaurants = jsonData['restaurants'] as List<dynamic>;
      return restaurants.map((json) => Restaurant.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load restaurants from assets: $e');
    }
  }

  // Get all restaurants for the current user (from Supabase)
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
      // Fallback to assets if Supabase fails
      return getRestaurantsFromAssets();
    }
  }

  // Get a restaurant by ID
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
      // Try assets if Supabase fails
      try {
        final restaurants = await getRestaurantsFromAssets();
        return restaurants.firstWhere((r) => r.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  // Get restaurants by city (from assets)
  Future<List<Restaurant>> getRestaurantsByCity(String city) async {
    try {
      final restaurants = await getRestaurantsFromAssets();
      return restaurants.where((r) => r.city.toLowerCase() == city.toLowerCase()).toList();
    } catch (e) {
      throw Exception('Failed to load restaurants by city: $e');
    }
  }

  // Search restaurants by query (from assets)
  Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      final restaurants = await getRestaurantsFromAssets();
      final lowerQuery = query.toLowerCase();
      return restaurants.where((r) =>
          r.name.toLowerCase().contains(lowerQuery) ||
          (r.cuisine?.toLowerCase().contains(lowerQuery) ?? false) ||
          (r.category?.toLowerCase().contains(lowerQuery) ?? false)
      ).toList();
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
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

  // Get all unique cities (from assets)
  Future<List<String>> getCities() async {
    try {
      final restaurants = await getRestaurantsFromAssets();
      final cities = restaurants.map((r) => r.city).toSet().toList();
      cities.sort();
      return cities;
    } catch (e) {
      return [];
    }
  }
}
