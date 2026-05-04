import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/restaurant_model.dart';

class RestaurantFilter {
  final String? city;
  final String? category;
  final double? minRating;
  final String? searchQuery;
  final PriceCategory? priceCategory;

  const RestaurantFilter({
    this.city,
    this.category,
    this.minRating,
    this.searchQuery,
    this.priceCategory,
  });

  RestaurantFilter copyWith({
    String? city,
    String? category,
    double? minRating,
    String? searchQuery,
    PriceCategory? priceCategory,
  }) {
    return RestaurantFilter(
      city: city ?? this.city,
      category: category ?? this.category,
      minRating: minRating ?? this.minRating,
      searchQuery: searchQuery ?? this.searchQuery,
      priceCategory: priceCategory ?? this.priceCategory,
    );
  }
}

class RestaurantRepository {
  static RestaurantRepository? _instance;
  List<RestaurantModel>? _cachedRestaurants;
  Map<String, dynamic>? _cachedMetadata;

  RestaurantRepository._();

  static RestaurantRepository get instance {
    _instance ??= RestaurantRepository._();
    return _instance!;
  }

  Future<List<RestaurantModel>> getAll() async {
    if (_cachedRestaurants != null) return _cachedRestaurants!;
    await _loadFromAssets();
    return _cachedRestaurants!;
  }

  Future<Map<String, dynamic>> getMetadata() async {
    if (_cachedMetadata != null) return _cachedMetadata!;
    await _loadFromAssets();
    return _cachedMetadata!;
  }

  Future<List<String>> getCities() async {
    final metadata = await getMetadata();
    final cities = (metadata['cities'] as List<dynamic>).cast<String>();
    return cities;
  }

  Future<List<String>> getCategories() async {
    final restaurants = await getAll();
    final categories = restaurants
        .map((r) => r.category)
        .whereType<String>()
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  Future<RestaurantModel?> getById(String id) async {
    final restaurants = await getAll();
    try {
      return restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<RestaurantModel>> getByCity(String city) async {
    final restaurants = await getAll();
    return restaurants
        .where((r) => r.city.toLowerCase() == city.toLowerCase())
        .toList();
  }

  Future<List<RestaurantModel>> filter(RestaurantFilter filter) async {
    var restaurants = await getAll();

    if (filter.city != null) {
      restaurants = restaurants
          .where((r) => r.city.toLowerCase() == filter.city!.toLowerCase())
          .toList();
    }

    if (filter.category != null) {
      restaurants = restaurants
          .where((r) =>
              r.category?.toLowerCase() == filter.category!.toLowerCase())
          .toList();
    }

    if (filter.minRating != null) {
      restaurants = restaurants.where((r) {
        final rating = r.rating ?? r.averageReviewRating;
        return rating != null && rating >= filter.minRating!;
      }).toList();
    }

    if (filter.priceCategory != null) {
      restaurants = restaurants
          .where((r) => r.priceCategory == filter.priceCategory)
          .toList();
    }

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      restaurants = restaurants.where((r) {
        return r.name.toLowerCase().contains(query) ||
            (r.cuisine?.toLowerCase().contains(query) ?? false) ||
            (r.category?.toLowerCase().contains(query) ?? false) ||
            (r.location?.toLowerCase().contains(query) ?? false) ||
            r.signatureDishes.any((d) => d.toLowerCase().contains(query));
      }).toList();
    }

    return restaurants;
  }

  Future<List<RestaurantModel>> search(String query) async {
    return filter(RestaurantFilter(searchQuery: query));
  }

  Future<List<RestaurantModel>> getTopRated({int limit = 10}) async {
    final restaurants = await getAll();
    final rated = restaurants.where((r) => r.rating != null).toList();
    rated.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return rated.take(limit).toList();
  }

  Future<void> _loadFromAssets() async {
    final jsonString =
        await rootBundle.loadString('assets/data/restaurants.json');
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    final restaurantsList = jsonData['restaurants'] as List<dynamic>;
    _cachedRestaurants = restaurantsList
        .map((json) => RestaurantModel.fromJson(json as Map<String, dynamic>))
        .toList();
    _cachedMetadata = jsonData['metadata'] as Map<String, dynamic>;
  }

  void clearCache() {
    _cachedRestaurants = null;
    _cachedMetadata = null;
  }
}