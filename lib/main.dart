import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/restaurant/screens/restaurant_list_screen.dart';
import 'features/restaurant/screens/restaurant_form_screen.dart';
import 'features/food_item/screens/food_list_screen.dart';
import 'features/food_item/screens/food_item_form_screen.dart';
import 'features/explore/screens/explore_screen.dart';
import 'features/restaurant/models/restaurant_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

final GoRouter _router = GoRouter(
  // Redirect to login if not authenticated, otherwise to the initially selected location
  redirect: (context, state) {
    final loggedIn = Supabase.instance.client.auth.currentUser != null;
    final loggingIn = state.subloc == '/login' || state.subloc == '/signup';

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/restaurants';
    return null; // No redirect needed
  },
  routes: [
    // Login and signup routes (outside of auth check)
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
      routes: [
        GoRoute(
          path: 'signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
      ],
    ),
    // Protected routes (require authentication)
    ShellRoute(
      builder: (context, state, child) {
        // Determine current tab index based on location
        final location = state.subloc;
        int currentIndex = 0;
        if (location.startsWith('/explore')) {
          currentIndex = 1;
        } else if (location.startsWith('/restaurants')) {
          currentIndex = 0;
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/restaurants');
                  break;
                case 1:
                  context.go('/explore');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant),
                label: 'Restaurants',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Explore',
              ),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/restaurants',
          name: 'restaurants',
          builder: (context, state) => const RestaurantListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              name: 'restaurant_add',
              builder: (context, state) => const RestaurantFormScreen(),
            ),
            GoRoute(
              path: ':restaurantId/edit',
              name: 'restaurant_edit',
              builder: (context, state) async {
                final restaurantId = state.params['restaurantId']!;
                final restaurant = await SupabaseService().getRestaurantById(restaurantId);
                return RestaurantFormScreen(
                  restaurantId: restaurantId,
                  restaurant: restaurant,
                );
              },
            ),
            GoRoute(
              path: ':restaurantId/food',
              name: 'food_list',
              builder: (context, state) async {
                final restaurantId = state.params['restaurantId']!;
                final restaurant = await SupabaseService().getRestaurantById(restaurantId);
                return FoodListScreen(
                  restaurantId: restaurantId,
                  restaurantName: restaurant.name,
                );
              },
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'food_add',
                  builder: (context, state) {
                    final restaurantId = state.params['restaurantId']!;
                    return FoodItemFormScreen(
                      restaurantId: restaurantId,
                    );
                  },
                ),
                GoRoute(
                  path: ':foodId/edit',
                  name: 'food_edit',
                  builder: (context, state) async {
                    final restaurantId = state.params['restaurantId']!;
                    final foodId = state.params['foodId']!;
                    final foodItemService = FoodItemService();
                    final foodItems = await foodItemService.getFoodItemsByRestaurant(restaurantId);
                    final foodItem = foodItems.firstWhere(
                      (item) => item.id == foodId,
                      orElse: () => FoodItem(
                        id: foodId,
                        restaurantId: restaurantId,
                        name: '',
                        price: 0,
                      ),
                    );
                    return FoodItemFormScreen(
                      restaurantId: restaurantId,
                      foodItem: foodItem,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/explore',
          name: 'explore',
          builder: (context, state) => const ExploreScreen(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FoodList',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  // Redirect to login if not authenticated, otherwise to the initially selected location
  redirect: (context, state) {
    final loggedIn = Supabase.instance.client.auth.currentUser != null;
    final loggingIn = state.subloc == '/login' || state.subloc == '/signup';

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/restaurants';
    return null; // No redirect needed
  },
  routes: [
    // Login and signup routes (outside of auth check)
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
      routes: [
        GoRoute(
          path: 'signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
      ],
    ),
    // Protected routes (require authentication)
    ShellRoute(
      builder: (context, state, child) => Scaffold(
        body: child,
        // We'll add a bottom navigation bar later for now just have the body
      ),
      routes: [
        GoRoute(
          path: '/restaurants',
          name: 'restaurants',
          builder: (context, state) => const RestaurantListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              name: 'restaurant_add',
              builder: (context, state) => const RestaurantFormScreen(),
            ),
            GoRoute(
              path: ':restaurantId',
              name: 'restaurant_detail',
              builder: (context, state) {
                final restaurantId = state.params['restaurantId']!;
                return RestaurantDetailScreen(restaurantId: restaurantId);
              },
            ),
            GoRoute(
              path: ':restaurantId/edit',
              name: 'restaurant_edit',
              builder: (context, state) async {
                final restaurantId = state.params['restaurantId']!;
                // Fetch the restaurant data for editing
                final restaurant = await SupabaseService().getRestaurantById(restaurantId);
                return RestaurantFormScreen(
                  restaurantId: restaurantId,
                  restaurant: restaurant,
                );
              },
            ),
            // Food item routes nested under a restaurant
            GoRoute(
              path: ':restaurantId/food',
              name: 'food_list',
              builder: (context, state) async {
                final restaurantId = state.params['restaurantId']!;
                // Fetch the restaurant name
                final restaurant = await SupabaseService().getRestaurantById(restaurantId);
                return FoodListScreen(
                  restaurantId: restaurantId,
                  restaurantName: restaurant.name,
                );
              },
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'food_add',
                  builder: (context, state) {
                    final restaurantId = state.params['restaurantId']!;
                    return FoodItemFormScreen(
                      restaurantId: restaurantId,
                    );
                  },
                ),
                GoRoute(
                  path: ':foodId',
                  name: 'food_item_detail',
                  builder: (context, state) {
                    final restaurantId = state.params['restaurantId']!;
                    final foodId = state.params['foodId']!;
                    return FoodItemDetailScreen(
                      restaurantId: restaurantId,
                      foodItemId: foodId,
                    );
                  },
                ),
                GoRoute(
                  path: ':foodId/edit',
                  name: 'food_edit',
                  builder: (context, state) async {
                    final restaurantId = state.params['restaurantId']!;
                    final foodId = state.params['foodId']!;
                    // Fetch the food item data for editing
                    final foodItemService = FoodItemService();
                    final foodItems = await foodItemService.getFoodItemsByRestaurant(restaurantId);
                    final foodItem = foodItems.firstWhere((item) => item.id == foodId, orElse: () => FoodItem(id: foodId, restaurantId: restaurantId, name: '', price: 0));
                    return FoodItemFormScreen(
                      restaurantId: restaurantId,
                      foodItem: foodItem,
                    );
                  },
                ),
                GoRoute(
                  path: ':foodId/reviews',
                  name: 'food_reviews',
                  builder: (context, state) {
                    final restaurantId = state.params['restaurantId']!;
                    final foodId = state.params['foodId']!;
                    final foodItemName = state.extra as String? ?? 'Food Item';
                    return ReviewScreen(
                      foodItemId: foodId,
                      foodItemName: foodItemName,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FoodList',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: _router,
    );
  }
}