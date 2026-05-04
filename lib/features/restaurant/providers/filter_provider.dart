import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant_model.dart';
import 'restaurant_provider.dart';

class RestaurantFilterState {
  final Set<String> selectedCities;
  final Set<String> selectedCuisines;
  final Set<String> selectedCategories;
  final Set<PriceCategory> selectedPriceCategories;
  final double? minRating;
  final String searchQuery;

  const RestaurantFilterState({
    this.selectedCities = const {},
    this.selectedCuisines = const {},
    this.selectedCategories = const {},
    this.selectedPriceCategories = const {},
    this.minRating,
    this.searchQuery = '',
  });

  bool get hasActiveFilters =>
      selectedCities.isNotEmpty ||
      selectedCuisines.isNotEmpty ||
      selectedCategories.isNotEmpty ||
      selectedPriceCategories.isNotEmpty ||
      minRating != null;

  int get activeFilterCount {
    int count = 0;
    if (selectedCities.isNotEmpty) count++;
    if (selectedCuisines.isNotEmpty) count++;
    if (selectedCategories.isNotEmpty) count++;
    if (selectedPriceCategories.isNotEmpty) count++;
    if (minRating != null) count++;
    return count;
  }

  RestaurantFilterState copyWith({
    Set<String>? selectedCities,
    Set<String>? selectedCuisines,
    Set<String>? selectedCategories,
    Set<PriceCategory>? selectedPriceCategories,
    double? minRating,
    bool clearMinRating = false,
    String? searchQuery,
  }) {
    return RestaurantFilterState(
      selectedCities: selectedCities ?? this.selectedCities,
      selectedCuisines: selectedCuisines ?? this.selectedCuisines,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedPriceCategories: selectedPriceCategories ?? this.selectedPriceCategories,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class RestaurantFilterNotifier extends StateNotifier<RestaurantFilterState> {
  RestaurantFilterNotifier() : super(const RestaurantFilterState());

  void setCity(String city, bool selected) {
    final cities = Set<String>.from(state.selectedCities);
    if (selected) {
      cities.add(city);
    } else {
      cities.remove(city);
    }
    state = state.copyWith(selectedCities: cities);
  }

  void setCuisine(String cuisine, bool selected) {
    final cuisines = Set<String>.from(state.selectedCuisines);
    if (selected) {
      cuisines.add(cuisine);
    } else {
      cuisines.remove(cuisine);
    }
    state = state.copyWith(selectedCuisines: cuisines);
  }

  void setCategory(String category, bool selected) {
    final categories = Set<String>.from(state.selectedCategories);
    if (selected) {
      categories.add(category);
    } else {
      categories.remove(category);
    }
    state = state.copyWith(selectedCategories: categories);
  }

  void setPriceCategory(PriceCategory priceCategory, bool selected) {
    final priceCategories = Set<PriceCategory>.from(state.selectedPriceCategories);
    if (selected) {
      priceCategories.add(priceCategory);
    } else {
      priceCategories.remove(priceCategory);
    }
    state = state.copyWith(selectedPriceCategories: priceCategories);
  }

  void setMinRating(double? rating) {
    if (rating == null) {
      state = state.copyWith(clearMinRating: true);
    } else {
      state = state.copyWith(minRating: rating);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearAll() {
    state = const RestaurantFilterState();
  }

  void clearCities() {
    state = state.copyWith(selectedCities: {});
  }

  void clearCuisines() {
    state = state.copyWith(selectedCuisines: {});
  }

  void clearCategories() {
    state = state.copyWith(selectedCategories: {});
  }

  void clearPriceCategories() {
    state = state.copyWith(selectedPriceCategories: {});
  }

  void clearMinRating() {
    state = state.copyWith(clearMinRating: true);
  }
}

final restaurantFilterProvider =
    StateNotifierProvider<RestaurantFilterNotifier, RestaurantFilterState>(
  (ref) => RestaurantFilterNotifier(),
);

final filteredRestaurantsProvider = Provider<AsyncValue<List<RestaurantModel>>>((ref) {
  final restaurantsAsync = ref.watch(restaurantsProvider);
  final filter = ref.watch(restaurantFilterProvider);

  return restaurantsAsync.when(
    data: (restaurants) {
      var filtered = restaurants.where((r) {
        if (filter.selectedCities.isNotEmpty &&
            !filter.selectedCities.contains(r.city)) {
          return false;
        }
        if (filter.selectedCuisines.isNotEmpty &&
            (r.cuisine == null ||
                !filter.selectedCuisines.any(
                    (c) => r.cuisine!.toLowerCase().contains(c.toLowerCase())))) {
          return false;
        }
        if (filter.selectedCategories.isNotEmpty &&
            (r.category == null ||
                !filter.selectedCategories.contains(r.category))) {
          return false;
        }
        if (filter.selectedPriceCategories.isNotEmpty &&
            !filter.selectedPriceCategories.contains(r.priceCategory)) {
          return false;
        }
        if (filter.minRating != null &&
            (r.averageReviewRating == null ||
                r.averageReviewRating! < filter.minRating!)) {
          return false;
        }
        if (filter.searchQuery.isNotEmpty) {
          final query = filter.searchQuery.toLowerCase();
          final matchesName = r.name.toLowerCase().contains(query);
          final matchesCuisine =
              r.cuisine?.toLowerCase().contains(query) ?? false;
          final matchesCategory =
              r.category?.toLowerCase().contains(query) ?? false;
          final matchesLocation =
              r.location?.toLowerCase().contains(query) ?? false;
          final matchesDishes = r.signatureDishes.any(
              (d) => d.toLowerCase().contains(query));
          if (!matchesName &&
              !matchesCuisine &&
              !matchesCategory &&
              !matchesLocation &&
              !matchesDishes) {
            return false;
          }
        }
        return true;
      }).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final filterOptionsProvider = FutureProvider<FilterOptions>((ref) async {
  final restaurants = await ref.watch(restaurantsProvider.future);
  final cities = restaurants.map((r) => r.city).toSet().toList()..sort();
  final cuisines = restaurants
      .map((r) => r.cuisine)
      .whereType<String>()
      .toSet()
      .toList()
    ..sort();
  final categories = restaurants
      .map((r) => r.category)
      .whereType<String>()
      .toSet()
      .toList()
    ..sort();
  final priceCategories = PriceCategory.values
      .where((pc) => pc != PriceCategory.unknown)
      .toList();
  return FilterOptions(
    cities: cities,
    cuisines: cuisines,
    categories: categories,
    priceCategories: priceCategories,
  );
});

class FilterOptions {
  final List<String> cities;
  final List<String> cuisines;
  final List<String> categories;
  final List<PriceCategory> priceCategories;

  const FilterOptions({
    required this.cities,
    required this.cuisines,
    required this.categories,
    required this.priceCategories,
  });
}