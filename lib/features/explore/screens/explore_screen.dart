import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../food_item/providers/food_item_provider.dart';
import '../../food_item/models/food_item_model.dart';
import '../../restaurant/repositories/restaurant_repository.dart';
import '../../restaurant/models/restaurant_model.dart';
import '../../food_item/providers/food_item_provider.dart' show allFoodItemsProvider;
import '../widgets/food_item_card.dart';

enum SortMode { trending, topRated, priceLowHigh, priceHighLow }

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  String _selectedCity = 'All';
  List<String> _cities = [];
  RangeValues _priceRange = const RangeValues(0, 100);
  double _minRating = 0;
  SortMode _sortMode = SortMode.trending;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await RestaurantRepository.instance.getCities();
      if (mounted) {
        setState(() {
          _cities = ['All', ...cities];
        });
      }
    } catch (e) {
      // Ignore error
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Price Range: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 200,
                    divisions: 20,
                    labels: RangeLabels(
                      '\$${_priceRange.start.round()}',
                      '\$${_priceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setModalState(() => _priceRange = values);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Minimum Rating: ${_minRating.toStringAsFixed(1)}+',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _minRating.toStringAsFixed(1),
                    onChanged: (value) {
                      setModalState(() => _minRating = value);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allFoodItemsAsync = ref.watch(allFoodItemsProvider);
    final notifier = ref.read(allFoodItemsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => notifier.setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search food items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              notifier.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (_cities.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _cities.length,
                    itemBuilder: (context, index) {
                      final city = _cities[index];
                      final isSelected = city == _selectedCity;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(city),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCity = city;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Trending'),
                      selected: _sortMode == SortMode.trending,
                      onSelected: (_) => setState(() => _sortMode = SortMode.trending),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Top Rated'),
                      selected: _sortMode == SortMode.topRated,
                      onSelected: (_) => setState(() => _sortMode = SortMode.topRated),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Budget'),
                      selected: _sortMode == SortMode.priceLowHigh,
                      onSelected: (_) => setState(() => _sortMode = SortMode.priceLowHigh),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: allFoodItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
        data: (foodItems) {
          // Filter by city, price, and rating
          var filteredItems = foodItems;
          if (_selectedCity != 'All') {
            filteredItems = foodItems.where((item) {
              return item.city == _selectedCity;
            }).toList();
          }

          // Filter by price range
          filteredItems = filteredItems.where((item) {
            return item.price >= _priceRange.start && item.price <= _priceRange.end;
          }).toList();

          // Filter by rating
          if (_minRating > 0) {
            filteredItems = filteredItems.where((item) {
              return (item.reviewScore ?? 0) >= _minRating;
            }).toList();
          }

          // Apply Sorting
          switch (_sortMode) {
            case SortMode.trending:
              filteredItems.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
              break;
            case SortMode.topRated:
              filteredItems.sort((a, b) => (b.reviewScore ?? 0).compareTo(a.reviewScore ?? 0));
              break;
            case SortMode.priceLowHigh:
              filteredItems.sort((a, b) => a.price.compareTo(b.price));
              break;
            case SortMode.priceHighLow:
              filteredItems.sort((a, b) => b.price.compareTo(a.price));
              break;
          }

          if (filteredItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.explore,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notifier.searchQuery.isEmpty && _selectedCity == 'All'
                        ? 'No food items found.'
                        : 'No food items match your search.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredItems.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  child: Text(
                    _searchController.text.isEmpty ? 'Trending Today' : 'Search Results',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                );
              }
              final foodItem = filteredItems[index - 1];
              return FoodItemCard(
                foodItem: foodItem,
                onTap: () {
                  context.push(
                    '/restaurants/${foodItem.restaurantId}/food/${foodItem.id}/edit',
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
