import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../widgets/restaurant_card.dart';
import '../features/restaurant/models/restaurant_model.dart';

class CityScreen extends StatefulWidget {
  final String cityId;

  const CityScreen({Key? key, required this.cityId}) : super(key: key);

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  List<RestaurantModel> _restaurants = [];
  bool _isLoading = true;
  String _searchQuery = '';

  String get _cityName {
    switch (widget.cityId) {
      case 'colombo':
        return 'Colombo';
      case 'vavuniya':
        return 'Vavuniya';
      case 'jaffna':
        return 'Jaffna';
      default:
        return widget.cityId;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/restaurants.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final restaurants = jsonData['restaurants'] as List<dynamic>;

      final cityRestaurants = restaurants
          .where((r) => r['city'] == widget.cityId)
          .map((r) => RestaurantModel.fromJson(r as Map<String, dynamic>))
          .toList();

      setState(() {
        _restaurants = cityRestaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<RestaurantModel> get _filteredRestaurants {
    if (_searchQuery.isEmpty) return _restaurants;
    return _restaurants.where((r) {
      return r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.cuisine.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRestaurants = _filteredRestaurants;

    return Scaffold(
      appBar: AppBar(
        title: Text(_cityName),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
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
          // Restaurant count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filteredRestaurants.length} restaurants found',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Restaurant list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRestaurants.isEmpty
                    ? Center(
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
                              _searchQuery.isEmpty
                                  ? 'No restaurants found in $_cityName'
                                  : 'No restaurants match your search',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: filteredRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = filteredRestaurants[index];
                          return RestaurantCard(
                            restaurant: restaurant,
                            onTap: () {
                              context.push('/city/${widget.cityId}/restaurant/${restaurant.id}');
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
