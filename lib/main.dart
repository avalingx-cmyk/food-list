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
import 'screens/home_screen.dart';
import 'screens/city_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

final GoRouter _router = GoRouter(
  redirect: (context, state) {
    final loggedIn = Supabase.instance.client.auth.currentUser != null;
    final loggingIn = state.subloc == '/login' || state.subloc == '/signup';

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/home';
    return null;
  },
  routes: [
    // Login and signup routes
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
    // Protected routes with bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        final location = state.subloc;
        int currentIndex = 0;
        if (location.startsWith('/explore')) {
          currentIndex = 1;
        } else if (location.startsWith('/restaurants')) {
          currentIndex = 2;
        } else if (location.startsWith('/home') || location.startsWith('/city')) {
          currentIndex = 0;
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.go('/explore');
                  break;
                case 2:
                  context.go('/restaurants');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Explore Cities',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant),
                label: 'My Restaurants',
              ),
            ],
          ),
        );
      },
      routes: [
        // Home screen with city cards
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        // City detail screen
        GoRoute(
          path: '/city/:cityId',
          name: 'city_detail',
          builder: (context, state) {
            final cityId = state.params['cityId']!;
            return CityScreen(cityId: cityId);
          },
        ),
        // Explore tab
        GoRoute(
          path: '/explore',
          name: 'explore',
          builder: (context, state) => const ExploreScreen(),
        ),
        // Restaurants management
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
