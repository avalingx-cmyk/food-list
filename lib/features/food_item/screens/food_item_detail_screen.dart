import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/food_item_provider.dart';
import '../providers/review_provider.dart';
import '../models/food_item_model.dart';
import 'review_screen.dart';

class FoodItemDetailScreen extends ConsumerWidget {
  final String restaurantId;
  final String foodItemId;

  const FoodItemDetailScreen({
    super.key,
    required this.restaurantId,
    required this.foodItemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodItemAsync = ref.watch(foodItemDetailProvider(foodItemId));
    final reviewsAsync = ref.watch(reviewsProvider(foodItemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Item Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/restaurants/$restaurantId/food/$foodItemId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Food Item'),
                  content: const Text('Are you sure you want to delete this food item? All associated reviews will also be deleted.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(foodItemsProvider(restaurantId).notifier).deleteFoodItem(foodItemId);
                if (context.mounted) context.go('/restaurants/$restaurantId/food');
              }
            },
          ),
        ],
      ),
      body: foodItemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (foodItem) {
          if (foodItem == null) {
            return const Center(child: Text('Food item not found'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food item details
                Text(
                  foodItem.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Price: \$${foodItem.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (foodItem.reviewScore != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${foodItem.reviewScore!.toStringAsFixed(1)}/5',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
                if (foodItem.photoUrl != null) ...[
                  const SizedBox(height: 16),
                  Image.network(
                    foodItem.photoUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const Icon(Icons.broken_image, size: 100),
                  ),
                ],
                const SizedBox(height: 24),
                // Reviews section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reviews',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.go(
                        '/restaurants/$restaurantId/food/$foodItemId/reviews',
                        extra: foodItem.name,
                      ),
                      child: const Text('Add Review'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: reviewsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error loading reviews: $error')),
                    data: (reviews) {
                      if (reviews.isEmpty) {
                        return const Center(child: Text('No reviews yet. Add one!'));
                      }
                      return ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text('${review.rating}'),
                            ),
                            title: Text(review.comment ?? 'No comment'),
                            subtitle: Text(
                              '${review.rating}/5 • ${review.createdAt?.toString().split(' ')[0] ?? ''}',
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
