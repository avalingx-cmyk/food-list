import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/restaurant_provider.dart';
import '../models/restaurant_model.dart';

class RestaurantDetailScreen extends ConsumerWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantDetailProvider(restaurantId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/restaurants/$restaurantId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Restaurant'),
                  content: const Text(
                      'Are you sure you want to delete this restaurant? All associated food items will also be deleted.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref
                    .read(restaurantsProvider.notifier)
                    .deleteRestaurant(restaurantId);
                if (context.mounted) context.go('/restaurants');
              }
            },
          ),
        ],
      ),
      body: restaurantAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (restaurant) {
          if (restaurant == null) {
            return const Center(child: Text('Restaurant not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                if (restaurant.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.rating!.toStringAsFixed(1)}/5',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Text(
                  'City: ${restaurant.city}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (restaurant.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(restaurant.location!)),
                    ],
                  ),
                ],
                if (restaurant.cuisine != null) ...[
                  const SizedBox(height: 8),
                  Chip(label: Text(restaurant.cuisine!)),
                ],
                if (restaurant.category != null) ...[
                  const SizedBox(height: 8),
                  Chip(
                      label: Text(restaurant.category!),
                      avatar: const Icon(Icons.restaurant_menu, size: 16)),
                ],
                if (restaurant.priceRange != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16),
                      const SizedBox(width: 4),
                      Text('Price: ${restaurant.priceRange!}'),
                    ],
                  ),
                ],
                if (restaurant.hours != null &&
                    restaurant.hours!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text('Hours: ${restaurant.hours!}'),
                    ],
                  ),
                ],
                if (restaurant.features != null &&
                    restaurant.features!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Features',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(restaurant.features!),
                ],
                if (restaurant.signatureDishes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Signature Dishes',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...restaurant.signatureDishes.map((dish) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('\u2022 ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(child: Text(dish)),
                          ],
                        ),
                      )),
                ],
                if (restaurant.userReviews.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('User Reviews',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...restaurant.userReviews.map((review) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (review.rating != null)
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < review.rating!.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(review.text),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      context.go('/restaurants/$restaurantId/food'),
                  child: const Text('View Food Items'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}