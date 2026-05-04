import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/restaurant/models/restaurant_model.dart';
import '../features/restaurant/providers/filter_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(restaurantFilterProvider);
    final filterOptions = ref.watch(filterOptionsProvider);
    final notifier = ref.read(restaurantFilterProvider.notifier);
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleLarge,
                ),
                if (filter.hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      notifier.clearAll();
                    },
                    child: const Text('Clear all'),
                  ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: theme.colorScheme.primary,
            tabs: [
              Tab(
                text: 'City${filter.selectedCities.isNotEmpty ? ' (${filter.selectedCities.length})' : ''}',
              ),
              Tab(
                text: 'Cuisine${filter.selectedCuisines.isNotEmpty ? ' (${filter.selectedCuisines.length})' : ''}',
              ),
              Tab(
                text: 'Category${filter.selectedCategories.isNotEmpty ? ' (${filter.selectedCategories.length})' : ''}',
              ),
              Tab(
                text: 'Price${filter.selectedPriceCategories.isNotEmpty ? ' (${filter.selectedPriceCategories.length})' : ''}',
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: filterOptions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error loading filters')),
              data: (options) => TabBarView(
                controller: _tabController,
                children: [
                  _buildCheckboxList(
                    items: options.cities,
                    selectedItems: filter.selectedCities,
                    onToggle: (city, selected) =>
                        notifier.setCity(city, selected),
                    onClearAll: () => notifier.clearCities(),
                  ),
                  _buildCheckboxList(
                    items: options.cuisines,
                    selectedItems: filter.selectedCuisines,
                    onToggle: (cuisine, selected) =>
                        notifier.setCuisine(cuisine, selected),
                    onClearAll: () => notifier.clearCuisines(),
                  ),
                  _buildCheckboxList(
                    items: options.categories,
                    selectedItems: filter.selectedCategories,
                    onToggle: (category, selected) =>
                        notifier.setCategory(category, selected),
                    onClearAll: () => notifier.clearCategories(),
                  ),
                  _buildPriceCategoryList(
                    priceCategories: options.priceCategories,
                    selectedCategories: filter.selectedPriceCategories,
                    onToggle: (pc, selected) =>
                        notifier.setPriceCategory(pc, selected),
                    onClearAll: () => notifier.clearPriceCategories(),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      notifier.clearAll();
                      Navigator.pop(context);
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Show results${filter.hasActiveFilters ? ' (${_getFilteredCount()})' : ''}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getFilteredCount() {
    final restaurantsAsync = ref.read(filteredRestaurantsProvider);
    return restaurantsAsync.whenOrNull(data: (data) => data.length) ?? 0;
  }

  Widget _buildCheckboxList({
    required List<String> items,
    required Set<String> selectedItems,
    required void Function(String, bool) onToggle,
    required VoidCallback onClearAll,
  }) {
    return Column(
      children: [
        if (selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onClearAll,
                  child: const Text('Deselect all'),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selectedItems.contains(item);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (checked) => onToggle(item, checked ?? false),
                title: Text(item),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                activeColor: Theme.of(context).colorScheme.primary,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCategoryList({
    required List<PriceCategory> priceCategories,
    required Set<PriceCategory> selectedCategories,
    required void Function(PriceCategory, bool) onToggle,
    required VoidCallback onClearAll,
  }) {
    const labels = {
      PriceCategory.budget: 'Budget & Street Food',
      PriceCategory.midRange: 'Mid-Range',
      PriceCategory.fineDining: 'Fine Dining',
      PriceCategory.unknown: 'Other',
    };
    const icons = {
      PriceCategory.budget: Icons.attach_money,
      PriceCategory.midRange: Icons.payments,
      PriceCategory.fineDining: Icons.diamond,
      PriceCategory.unknown: Icons.category,
    };

    return Column(
      children: [
        if (selectedCategories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onClearAll,
                  child: const Text('Deselect all'),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: priceCategories.length,
            itemBuilder: (context, index) {
              final pc = priceCategories[index];
              final isSelected = selectedCategories.contains(pc);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (checked) => onToggle(pc, checked ?? false),
                title: Row(
                  children: [
                    Icon(icons[pc], size: 20),
                    const SizedBox(width: 8),
                    Text(labels[pc] ?? pc.name),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                activeColor: Theme.of(context).colorScheme.primary,
              );
            },
          ),
        ),
      ],
    );
  }
}

Future<void> showFilterBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const FilterBottomSheet(),
  );
}