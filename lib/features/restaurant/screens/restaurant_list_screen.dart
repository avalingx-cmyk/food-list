import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/restaurant_model.dart';
import '../providers/restaurant_provider.dart';
import '../screens/restaurant_form_screen.dart';

class RestaurantListScreen extends ConsumerWidget {
  const RestaurantListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
      ),
      body: restaurantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
        data: (restaurants) {
          if (restaurants.isEmpty) {
            return const Center(
              child: Text('No restaurants found. Tap the + button to add one.'),
            );
          }
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return ListTile(
                leading: const Icon(Icons.restaurant),
                title: Text(restaurant.name),
                subtitle: Text(restaurant.city),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await context.push('/restaurants/${restaurant.id}/edit');
                      // Refresh the list after returning from the edit screen
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
                                    .deleteRestaurant(restaurant.id!);
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
                  // On tap, we could navigate to a detail screen or just edit for now
                  context.push('/restaurants/${restaurant.id}/edit');
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/restaurants/add');
          // Refresh the list after returning from the form screen
          ref.refresh(restaurantsProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}