import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/restaurant_model.dart';
import '../providers/restaurant_provider.dart';
import 'restaurant_form_screen.dart';
import 'restaurant_detail_screen.dart';

class RestaurantListScreen extends ConsumerStatefulWidget {
  const RestaurantListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends ConsumerState<RestaurantListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantsProvider);
    final notifier = ref.read(restaurantsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants (47)'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => notifier.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
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
        ),
      ),
      body: restaurantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
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
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notifier.searchQuery.isEmpty
                        ? 'No restaurants found. Tap the + button to add one.'
                        : 'No restaurants match your search.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    restaurant.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (restaurant.rating != null) ...[
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating!.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.city),
                    if (restaurant.cuisine != null)
                      Text(
                        restaurant.cuisine!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await context.push('/restaurants/${restaurant.id}/edit');
                      ref.refresh(restaurantsProvider);
                    } else if (value == 'delete') {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Restaurant'),
                          content: Text(
                              'Are you sure you want to delete ${restaurant.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await ref
                                    .read(restaurantServiceProvider)
                                    .deleteRestaurant(restaurant.id);
                                ref.refresh(restaurantsProvider);
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
                  context.push('/restaurants/${restaurant.id}');
                },
              );
            },
          );
        },
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
}
