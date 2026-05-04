import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/restaurant_card.dart';
import '../features/restaurant/models/restaurant_model.dart';
import '../features/restaurant/providers/restaurant_provider.dart';

class CityScreen extends ConsumerStatefulWidget {
  final String cityId;

  const CityScreen({Key? key, required this.cityId}) : super(key: key);

  @override
  ConsumerState<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends ConsumerState<CityScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  double? _minRating;

  String get _cityName {
    switch (widget.cityId) {
      case 'colombo':
        return 'Colombo';
      case 'vavuniya':
        return 'Vavuniya';
      case 'jaffna':
        return 'Jaffna';
      default:
        return widget.cityId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantsByCityProvider(widget.cityId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_cityName),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 40,
              child: ref.watch(categoriesProvider).when(
                    data: (categories) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: const Text('All'),
                              selected: _selectedCategory == null,
                              onSelected: (_) =>
                                  setState(() => _selectedCategory = null),
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                            ),
                          );
                        }
                        final category = categories[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (_) => setState(() =>
                                _selectedCategory =
                                    _selectedCategory == category
                                        ? null
                                        : category),
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            selectedColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                          ),
                        );
                      },
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Min Rating:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                DropdownButton<double?>(
                  value: _minRating,
                  items: [null, 3.0, 3.5, 4.0, 4.5]
                      .map((v) => DropdownMenuItem<double?>(
                            value: v,
                            child: Text(v == null ? 'Any' : '${v.toStringAsFixed(1)}+'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _minRating = v),
                  underline: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Expanded(
            child: restaurantsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (restaurants) {
                var filtered = restaurants;
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered.where((r) {
                    return r.name.toLowerCase().contains(q) ||
                        (r.cuisine?.toLowerCase().contains(q) ?? false) ||
                        (r.category?.toLowerCase().contains(q) ?? false);
                  }).toList();
                }
                if (_selectedCategory != null) {
                  filtered = filtered
                      .where((r) => r.category == _selectedCategory)
                      .toList();
                }
                if (_minRating != null) {
                  filtered = filtered.where((r) {
                    final rating = r.rating ?? r.averageReviewRating;
                    return rating != null && rating >= _minRating!;
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _selectedCategory == null
                              ? 'No restaurants found in $_cityName'
                              : 'No restaurants match your filters',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final restaurant = filtered[index];
                    return RestaurantCard(
                      restaurant: restaurant,
                      onTap: () {
                        context.push(
                            '/city/${widget.cityId}/restaurant/${restaurant.id}');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}