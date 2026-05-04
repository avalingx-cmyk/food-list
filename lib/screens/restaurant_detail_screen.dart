import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/restaurant/models/restaurant_model.dart';
import '../features/restaurant/providers/restaurant_provider.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String cityId;
  final String restaurantId;

  const RestaurantDetailScreen({
    Key? key,
    required this.cityId,
    required this.restaurantId,
  }) : super(key: key);

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final restaurantAsync =
        ref.watch(restaurantDetailProvider(widget.restaurantId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant'),
      ),
      body: restaurantAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Error loading restaurant',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
        data: (restaurant) {
          if (restaurant == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Restaurant not found',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                if (restaurant.cuisine != null)
                  Text(
                    restaurant.cuisine!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (restaurant.rating != null) ...[
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (restaurant.priceRange != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          restaurant.priceRange!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (restaurant.category != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(restaurant.category!),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                if (restaurant.features != null &&
                    restaurant.features!.isNotEmpty) ...[
                  Text('About',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(restaurant.features!,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                ],
                Text('Location',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        restaurant.location ?? 'Address not available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                if (restaurant.hours != null &&
                    restaurant.hours!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(restaurant.hours!,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
                if (restaurant.signatureDishes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Signature Dishes',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...restaurant.signatureDishes.map(
                    (dish) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.restaurant_menu,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(dish,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (restaurant.userReviews.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Reviews',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...restaurant.userReviews.map((review) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (review.rating != null)
                                Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (i) => Icon(
                                        i < review.rating!.round()
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(review.rating!.toStringAsFixed(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              Text(review.text),
                            ],
                          ),
                        ),
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}