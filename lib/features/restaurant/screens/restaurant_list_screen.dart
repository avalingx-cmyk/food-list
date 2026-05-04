import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/restaurant_model.dart';
import '../providers/restaurant_provider.dart';
import '../providers/filter_provider.dart';
import '../../../widgets/filter_bottom_sheet.dart';
import '../../../widgets/restaurant_card.dart';

class RestaurantListScreen extends ConsumerStatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  ConsumerState<RestaurantListScreen> createState() =>
      _RestaurantListScreenState();
}

class _RestaurantListScreenState extends ConsumerState<RestaurantListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(restaurantFilterProvider).searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredRestaurantsProvider);
    final filter = ref.watch(restaurantFilterProvider);
    final filterNotifier = ref.read(restaurantFilterProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filter.hasActiveFilters,
              label: Text('${filter.activeFilterCount}'),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => showFilterBottomSheet(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => filterNotifier.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          filterNotifier.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (filter.hasActiveFilters) _buildActiveFilters(filter, filterNotifier, theme),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Error: $error', textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.refresh(restaurantsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (restaurants) {
                if (restaurants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          filter.searchQuery.isEmpty && !filter.hasActiveFilters
                              ? 'No restaurants found.'
                              : 'No restaurants match your filters.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                        if (filter.hasActiveFilters) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => filterNotifier.clearAll(),
                            child: const Text('Clear filters'),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        '${restaurants.length} restaurant${restaurants.length == 1 ? '' : 's'} found',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: restaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = restaurants[index];
                          return RestaurantCard(
                            restaurant: restaurant,
                            onTap: () {
                              context.push(
                                '/city/${restaurant.city}/restaurant/${restaurant.id}',
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/restaurants/add');
          ref.refresh(restaurantsProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActiveFilters(
    RestaurantFilterState filter,
    RestaurantFilterNotifier notifier,
    ThemeData theme,
  ) {
    final chips = <Widget>[];

    for (final city in filter.selectedCities) {
      chips.add(_buildFilterChip(
        label: city,
        onRemove: () => notifier.setCity(city, false),
        theme: theme,
      ));
    }
    for (final cuisine in filter.selectedCuisines) {
      chips.add(_buildFilterChip(
        label: cuisine,
        onRemove: () => notifier.setCuisine(cuisine, false),
        theme: theme,
      ));
    }
    for (final category in filter.selectedCategories) {
      chips.add(_buildFilterChip(
        label: category,
        onRemove: () => notifier.setCategory(category, false),
        theme: theme,
      ));
    }
    for (final pc in filter.selectedPriceCategories) {
      const labels = {
        PriceCategory.budget: 'Budget',
        PriceCategory.midRange: 'Mid-Range',
        PriceCategory.fineDining: 'Fine Dining',
        PriceCategory.unknown: 'Other',
      };
      chips.add(_buildFilterChip(
        label: labels[pc] ?? pc.name,
        onRemove: () => notifier.setPriceCategory(pc, false),
        theme: theme,
      ));
    }
    if (filter.minRating != null) {
      chips.add(_buildFilterChip(
        label: '${filter.minRating}+ stars',
        onRemove: () => notifier.clearMinRating(),
        theme: theme,
      ));
    }

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: chips,
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: InputChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onDeleted: onRemove,
        deleteIconColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
        labelStyle: TextStyle(color: theme.colorScheme.primary),
      ),
    );
  }
}