import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/restaurant/models/restaurant_model.dart';
import '../features/restaurant/providers/restaurant_provider.dart';
import '../core/theme/app_theme.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String cityId;
  final String restaurantId;

  const RestaurantDetailScreen({
    super.key,
    required this.cityId,
    required this.restaurantId,
  });

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
                _buildHeader(restaurant),
                const SizedBox(height: 16),
                _buildInfoChips(restaurant),
                const SizedBox(height: 24),
                if (restaurant.features.isNotEmpty) ...[
                  _buildSection(
                    title: 'About',
                    icon: Icons.info_outline,
                    child: Text(
                      restaurant.features!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                _buildSection(
                  title: 'Location & Hours',
                  icon: Icons.location_on,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (restaurant.location != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.place, size: 16,
                                color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(restaurant.location!,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      if (restaurant.location != null) const SizedBox(height: 8),
                      if (restaurant.hours != null)
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16,
                                color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(restaurant.hours!,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (restaurant.signatureDishes.isNotEmpty) ...[
                  _buildSection(
                    title: 'Menu & Signature Dishes',
                    icon: Icons.restaurant_menu,
                    child: Column(
                      children: restaurant.signatureDishes.map((dish) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppTheme.primary.withOpacity(0.15)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.restaurant_menu,
                                    size: 16, color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(dish,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (restaurant.userReviews.isNotEmpty) ...[
                  _buildSection(
                    title: 'Reviews',
                    icon: Icons.rate_review,
                    child: Column(
                      children: restaurant.userReviews.map((review) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                                    Text(
                                      review.rating!.toStringAsFixed(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              if (review.text.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(review.text,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(RestaurantModel restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.restaurant, size: 64, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Text(
          restaurant.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (restaurant.cuisine != null) ...[
          const SizedBox(height: 4),
          Text(
            restaurant.cuisine!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primary,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChips(RestaurantModel restaurant) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (restaurant.rating != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  restaurant.rating!.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        if (restaurant.category != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.category, size: 16, color: AppTheme.secondary),
                const SizedBox(width: 4),
                Text(restaurant.category!,
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        if (restaurant.priceRange != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payments, size: 16, color: AppTheme.accent),
                const SizedBox(width: 4),
                Text(restaurant.priceRange!,
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}