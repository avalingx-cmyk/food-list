import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/food_item_model.dart';
import '../providers/food_item_provider.dart';
import 'food_item_form_screen.dart';

class FoodListScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const FoodListScreen({
    Key? key,
    required this.restaurantId,
    required this.restaurantName,
  }) : super(key: key);

  @override
  ConsumerState<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends ConsumerState<FoodListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foodItemsAsync = ref.watch(foodItemsProvider(widget.restaurantId));
    final foodItemsNotifier = ref.read(foodItemsProvider(widget.restaurantId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'price_low_high':
                  foodItemsNotifier.setSortOptions(sortBy: 'price', ascending: true);
                  break;
                case 'price_high_low':
                  foodItemsNotifier.setSortOptions(sortBy: 'price', ascending: false);
                  break;
                case 'rating_low_high':
                  foodItemsNotifier.setSortOptions(sortBy: 'review_score', ascending: true);
                  break;
                case 'rating_high_low':
                  foodItemsNotifier.setSortOptions(sortBy: 'review_score', ascending: false);
                  break;
                case 'name_a_z':
                  foodItemsNotifier.setSortOptions(sortBy: 'name', ascending: true);
                  break;
                case 'name_z_a':
                  foodItemsNotifier.setSortOptions(sortBy: 'name', ascending: false);
                  break;
                case 'newest':
                  foodItemsNotifier.setSortOptions(sortBy: 'created_at', ascending: false);
                  break;
                case 'oldest':
                  foodItemsNotifier.setSortOptions(sortBy: 'created_at', ascending: true);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'price_low_high', child: Text('Price: Low to High')),
              const PopupMenuItem(value: 'price_high_low', child: Text('Price: High to Low')),
              const PopupMenuItem(value: 'rating_low_high', child: Text('Rating: Low to High')),
              const PopupMenuItem(value: 'rating_high_low', child: Text('Rating: High to Low')),
              const PopupMenuItem(value: 'name_a_z', child: Text('Name: A to Z')),
              const PopupMenuItem(value: 'name_z_a', child: Text('Name: Z to A')),
              const PopupMenuItem(value: 'newest', child: Text('Newest First')),
              const PopupMenuItem(value: 'oldest', child: Text('Oldest First')),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => foodItemsNotifier.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search food items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          foodItemsNotifier.setSearchQuery('');
                        },
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
          Expanded(
            child: foodItemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error: $error'),
              ),
              data: (foodItems) {
                if (foodItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fastfood,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          foodItemsNotifier.searchQuery.isEmpty
                              ? 'No food items found. Tap the + button to add one.'
                              : 'No food items match your search.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: foodItems.length,
                  itemBuilder: (context, index) {
                    final foodItem = foodItems[index];
                    return ListTile(
                      leading: foodItem.photoUrl != null
                          ? Image.network(
                              foodItem.photoUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.fastfood),
                            )
                          : const Icon(Icons.fastfood),
                      title: Text(foodItem.name),
                      subtitle: Text(
                        '\$${foodItem.price.toStringAsFixed(2)} '
                        '${foodItem.reviewScore != null ? '(Rating: ${foodItem.reviewScore!.toStringAsFixed(1)})' : ''}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await context.push(
                              '/restaurant/${widget.restaurantId}/food/${foodItem.id}/edit',
                            );
                            ref.refresh(foodItemsProvider(widget.restaurantId));
                          } else if (value == 'delete') {
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Food Item'),
                                content: Text(
                                    'Are you sure you want to delete ${foodItem.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await ref
                                          .read(foodItemServiceProvider)
                                          .deleteFoodItem(foodItem.id!);
                                      ref.refresh(foodItemsProvider(widget.restaurantId));
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                      onTap: () {
                        context.push(
                          '/restaurant/${widget.restaurantId}/food/${foodItem.id}/edit',
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(
            '/restaurant/${widget.restaurantId}/food/add',
          );
          ref.refresh(foodItemsProvider(widget.restaurantId));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
            },
            