import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant_model.dart';
import '../repositories/restaurant_repository.dart';

final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  return RestaurantService();
});

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return RestaurantRepository.instance;
});

final restaurantsProvider =
    StateNotifierProvider<RestaurantsNotifier, AsyncValue<List<RestaurantModel>>>(
        (ref) {
  return RestaurantsNotifier(ref.read(restaurantServiceProvider));
});

class RestaurantsNotifier extends StateNotifier<AsyncValue<List<RestaurantModel>>> {
  final RestaurantService _restaurantService;
  RestaurantFilter _filter = const RestaurantFilter();

  RestaurantsNotifier(this._restaurantService)
      : super(const AsyncValue.loading()) {
    fetchRestaurants();
  }

  RestaurantFilter get currentFilter => _filter;

  void setFilter(RestaurantFilter filter) {
    _filter = filter;
    fetchRestaurants();
  }

  void setSearchQuery(String query) {
    _filter = _filter.copyWith(searchQuery: query);
    fetchRestaurants();
  }

  void setCity(String? city) {
    _filter = _filter.copyWith(city: city);
    fetchRestaurants();
  }

  void setCategory(String? category) {
    _filter = _filter.copyWith(category: category);
    fetchRestaurants();
  }

  void setMinRating(double? minRating) {
    _filter = _filter.copyWith(minRating: minRating);
    fetchRestaurants();
  }

  void setPriceCategory(PriceCategory? priceCategory) {
    _filter = _filter.copyWith(priceCategory: priceCategory);
    fetchRestaurants();
  }

  void clearFilters() {
    _filter = const RestaurantFilter();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    state = const AsyncValue.loading();
    try {
      final repository = RestaurantRepository.instance;
      final restaurants = await repository.filter(_filter);
      state = AsyncValue.data(restaurants);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addRestaurant(RestaurantModel restaurant) async {
    try {
      await _restaurantService.addRestaurant(restaurant);
      await fetchRestaurants();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateRestaurant(RestaurantModel restaurant) async {
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

final restaurantDetailProvider =
    FutureProvider.family<RestaurantModel?, String>((ref, id) async {
  final repository = ref.read(restaurantRepositoryProvider);
  return repository.getById(id);
});

final restaurantAssetsProvider =
    FutureProvider<List<RestaurantModel>>((ref) async {
  final repository = ref.read(restaurantRepositoryProvider);
  return repository.getAll();
});

final restaurantsByCityProvider =
    FutureProvider.family<List<RestaurantModel>, String>((ref, city) async {
  final repository = ref.read(restaurantRepositoryProvider);
  return repository.getByCity(city);
});

final searchRestaurantsProvider =
    FutureProvider.family<List<RestaurantModel>, String>((ref, query) async {
  final repository = ref.read(restaurantRepositoryProvider);
  return repository.search(query);
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.read(restaurantRepositoryProvider);
  return repository.getCategories();
});

final topRatedRestaurantsProvider =
    FutureProvider<List<RestaurantModel>>((ref) async {
  final repository = ref.read(restaurantRepositoryProvider);
  return repository.getTopRated();
});