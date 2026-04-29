import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/food_item_model.dart';
import '../providers/food_item_provider.dart';
import 'food_item_form_screen.dart';

class FoodListScreen extends ConsumerWidget {
  final String restaurantId;
  final String restaurantName;

  const FoodListScreen({
    Key? key,
    required this.restaurantId,
    required this.restaurantName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodItemsAsync = ref.watch(foodItemsProvider(restaurantId));
    final foodItemsNotifier = ref.read(foodItemsProvider(restaurantId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('$restaurantName - Food Items'),
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push(
                '/restaurant/$restaurantId/food/add',
              );
              // Refresh the list after returning from the form screen
              ref.refresh(foodItemsProvider(restaurantId));
            },
          ),
        ],
      ),
      body: foodItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
        data: (foodItems) {
          if (foodItems.isEmpty) {
            return const Center(
              child: Text('No food items found. Tap the + button to add one.'),
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
                        '/restaurant/$restaurantId/food/${foodItem.id}/edit',
                      );
                      // Refresh the list after returning from the edit screen
                      ref.refresh(foodItemsProvider(restaurantId));
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
                                ref.refresh(foodItemsProvider(restaurantId));
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
                  // On tap, we could navigate to a detail screen or just edit for now
                  context.push(
                    '/restaurant/$restaurantId/food/${foodItem.id}/edit',
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