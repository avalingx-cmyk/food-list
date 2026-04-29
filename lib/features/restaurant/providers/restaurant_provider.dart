import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant_model.dart';

// Provider for the restaurant service
final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  return RestaurantService();
});

// Provider for fetching and managing the list of restaurants
final restaurantsProvider = StateNotifierProvider<RestaurantsNotifier, AsyncValue<List<Restaurant>>>((ref) {
  return RestaurantsNotifier(ref.read(restaurantServiceProvider));
});

class RestaurantsNotifier extends StateNotifier<AsyncValue<List<Restaurant>>> {
  final RestaurantService _restaurantService;

  RestaurantsNotifier(this._restaurantService) : super(const AsyncValue.loading()) {
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    state = const AsyncValue.loading();
    try {
      final restaurants = await _restaurantService.getRestaurants();
      state = AsyncValue.data(restaurants);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addRestaurant(Restaurant restaurant) async {
    try {
      await _restaurantService.addRestaurant(restaurant);
      await fetchRestaurants(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateRestaurant(Restaurant restaurant) async {
    try {
      await _restaurantService.updateRestaurant(restaurant);
      await fetchRestaurants(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteRestaurant(String id) async {
    try {
      await _restaurantService.deleteRestaurant(id);
      await fetchRestaurants(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}