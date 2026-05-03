import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/food_item_service.dart';
import '../models/food_item_model.dart';

// Provider for the food item service
final foodItemServiceProvider = Provider<FoodItemService>((ref) {
  return FoodItemService();
});

// Provider for fetching a single food item by ID
final foodItemDetailProvider = FutureProvider.family<FoodItem?, String>((ref, id) async {
  final service = ref.read(foodItemServiceProvider);
  return service.getFoodItemById(id);
});

// StateNotifier for managing the list of food items for a specific restaurant
class FoodItemsNotifier extends StateNotifier<AsyncValue<List<FoodItem>>> {
  final FoodItemService _foodItemService;
  final String _restaurantId;
  String _sortBy = 'created_at';
  bool _ascending = false;
  String _searchQuery = '';

  FoodItemsNotifier(this._foodItemService, this._restaurantId)
      : super(const AsyncValue.loading()) {
    _loadFoodItems();
  }

  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _loadFoodItems();
  }

  void setSortOptions({String? sortBy, bool? ascending}) {
    if (sortBy != null) _sortBy = sortBy;
    if (ascending != null) _ascending = ascending;
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    state = const AsyncValue.loading();
    try {
      final foodItems = await _foodItemService.getFoodItemsByRestaurant(
        _restaurantId,
        sortBy: _sortBy,
        ascending: _ascending,
        searchQuery: _searchQuery,
      );
      state = AsyncValue.data(foodItems);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addFoodItem(FoodItem foodItem) async {
    try {
      await _foodItemService.addFoodItem(foodItem);
      await _loadFoodItems(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateFoodItem(FoodItem foodItem) async {
    try {
      await _foodItemService.updateFoodItem(foodItem);
      await _loadFoodItems(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteFoodItem(String id) async {
    try {
      await _foodItemService.deleteFoodItem(id);
      await _loadFoodItems(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Provider family that takes a restaurantId and returns a FoodItemsNotifier
final foodItemsProvider = StateNotifierProvider.family
    <FoodItemsNotifier, AsyncValue<List<FoodItem>>, String>((ref, restaurantId) {
  return FoodItemsNotifier(ref.read(foodItemServiceProvider), restaurantId);
});

// Provider for getting all food items (for explore tab)
final allFoodItemsProvider = StateNotifierProvider<AllFoodItemsNotifier, AsyncValue<List<FoodItem>>>((ref) {
  return AllFoodItemsNotifier(ref.read(foodItemServiceProvider));
});

class AllFoodItemsNotifier extends StateNotifier<AsyncValue<List<FoodItem>>> {
  final FoodItemService _foodItemService;
  String _sortBy = 'created_at';
  bool _ascending = false;
  String _searchQuery = '';

  AllFoodItemsNotifier(this._foodItemService) : super(const AsyncValue.loading()) {
    _loadAllFoodItems();
  }

  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _loadAllFoodItems();
  }

  void setSortOptions({String? sortBy, bool? ascending}) {
    if (sortBy != null) _sortBy = sortBy;
    if (ascending != null) _ascending = ascending;
    _loadAllFoodItems();
  }

  Future<void> _loadAllFoodItems() async {
    state = const AsyncValue.loading();
    try {
      final foodItems = await _foodItemService.getAllFoodItems(
        sortBy: _sortBy,
        ascending: _ascending,
        searchQuery: _searchQuery,
      );
      state = AsyncValue.data(foodItems);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // We don't implement add/update/delete here because we are just reading for explore.
  // If we want to allow editing from the explore tab, we would need to add those methods.
}