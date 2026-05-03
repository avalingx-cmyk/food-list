import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final RangeValues? priceRange;
  final RangeValues? currentPriceRange;
  final Function(String?) onCategoryChanged;
  final Function(RangeValues)? onPriceRangeChanged;

  const FilterBar({
    Key? key,
    required this.categories,
    this.selectedCategory,
    this.priceRange,
    this.currentPriceRange,
    required this.onCategoryChanged,
    this.onPriceRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Category filter chips
          ...categories.map((category) {
            final isSelected = category == selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  onCategoryChanged(selected ? category : null);
                },
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
          // Price range filter
          if (onPriceRangeChanged != null && priceRange != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ActionChip(
                label: Text(
                  currentPriceRange != null
                      ? '\$${currentPriceRange!.start.toInt()}-\$${currentPriceRange!.end.toInt()}'
                      : 'Price',
                ),
                onPressed: () async {
                  final result = await showDialog<RangeValues>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Filter by Price'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RangeSlider(
                            values: currentPriceRange ?? priceRange!,
                            min: priceRange!.start,
                            max: priceRange!.end,
                            divisions: 10,
                            labels: RangeLabels(
                              '\$${(currentPriceRange ?? priceRange!).start.toInt()}',
                              '\$${(currentPriceRange ?? priceRange!).end.toInt()}',
                            ),
                            onChanged: (values) {
                              // Handle in real-time or use a StatefulBuilder
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, currentPriceRange ?? priceRange!),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  );
                  if (result != null) {
                    onPriceRangeChanged!(result);
                  }
                },
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
            ),
        ],
      ),
    );
  }
}
