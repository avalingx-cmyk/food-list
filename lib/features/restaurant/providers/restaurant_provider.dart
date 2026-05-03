import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant_model.dart';

// Provider for the restaurant service
final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  return RestaurantService();
});

// Provider for fetching and managing the list of restaurants (from Supabase with asset fallback)
final restaurantsProvider = StateNotifierProvider<RestaurantsNotifier, AsyncValue<List<Restaurant>>>((ref) {
  return RestaurantsNotifier(ref.read(restaurantServiceProvider));
});

class RestaurantsNotifier extends StateNotifier<AsyncValue<List<Restaurant>>> {
  final RestaurantService _restaurantService;
  String _searchQuery = '';

  RestaurantsNotifier(this._restaurantService) : super(const AsyncValue.loading()) {
    fetchRestaurants();
  }

  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    state = const AsyncValue.loading();
    try {
      final restaurants = await _restaurantService.getRestaurantsFromAssets();
      state = AsyncValue.data(restaurants);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addRestaurant(Restaurant restaurant) async {
    try {
      await _restaurantService.addRestaurant(restaurant);
      await fetchRestaurants();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateRestaurant(Restaurant restaurant) async {
    try {
      await _restaurantService.updateRestaurant(restaurant);
      await fetchRestaurants();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteRestaurant(String id) async {
    try {
      await _restaurantService.deleteRestaurant(id);
      await fetchRestaurants();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Provider for fetching a single restaurant by ID
final restaurantDetailProvider = FutureProvider.family<Restaurant?, String>((ref, id) async {
  final service = ref.read(restaurantServiceProvider);
  return service.getRestaurantById(id);
});

// Provider for loading all restaurants from local JSON assets
final restaurantAssetsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final service = ref.read(restaurantServiceProvider);
  return service.getRestaurantsFromAssets();
});

// Provider for loading restaurants by city from assets
final restaurantsByCityProvider = FutureProvider.family<List<Restaurant>, String>((ref, city) async {
  final service = ref.read(restaurantServiceProvider);
  return service.getRestaurantsByCity(city);
});

// Provider for searching restaurants from assets
final searchRestaurantsProvider = FutureProvider.family<List<Restaurant>, String>((ref, query) async {
  final service = ref.read(restaurantServiceProvider);
  return service.searchRestaurants(query);
});
