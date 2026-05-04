import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_model.dart';
import '../repositories/restaurant_repository.dart';

class RestaurantService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final RestaurantRepository _repository = RestaurantRepository.instance;

  Future<List<RestaurantModel>> getRestaurantsFromAssets() async {
    return _repository.getAll();
  }

  Future<List<RestaurantModel>> getRestaurants() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('restaurants')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RestaurantModel.fromJson(json))
          .toList();
    } catch (e) {
      return getRestaurantsFromAssets();
    }
  }

  Future<RestaurantModel?> getRestaurantById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e) {
      return null;
    }
  }

  Future<List<RestaurantModel>> getRestaurantsByCity(String city) async {
    return _repository.getByCity(city);
  }

  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    return _repository.search(query);
  }

  Future<List<String>> getCities() async {
    return _repository.getCities();
  }

  Future<List<String>> getCategories() async {
    return _repository.getCategories();
  }

  Future<RestaurantModel> addRestaurant(RestaurantModel restaurant) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final restaurantData = restaurant.toJson();
      restaurantData['user_id'] = user.id;

      final response = await _supabase
          .from('restaurants')
          .insert(restaurantData)
          .select()
          .single();

      return RestaurantModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add restaurant: $e');
    }
  }

  Future<RestaurantModel> updateRestaurant(RestaurantModel restaurant) async {
    try {
      final response = await _supabase
          .from('restaurants')
          .update(restaurant.toJson())
          .eq('id', restaurant.id)
          .select()
          .single();

      return RestaurantModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update restaurant: $e');
    }
  }

  Future<void> deleteRestaurant(String id) async {
    try {
      await _supabase.from('restaurants').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete restaurant: $e');
    }
  }
}