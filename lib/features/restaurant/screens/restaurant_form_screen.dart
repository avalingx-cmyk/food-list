import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant_model.dart';
import '../services/restaurant_service.dart';
import '../providers/restaurant_provider.dart';

class RestaurantFormScreen extends ConsumerStatefulWidget {
  final String? restaurantId; // If null, we are adding; if provided, we are editing.

  const RestaurantFormScreen({
    Key? key,
    this.restaurantId,
  }) : super(key: key);

  @override
  ConsumerState<RestaurantFormScreen> createState() => _RestaurantFormScreenState();
}

class _RestaurantFormScreenState extends ConsumerState<RestaurantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch the restaurant data if we are editing and haven't initialized yet
    if (widget.restaurantId != null && !_isInitialized) {
      _isInitialized = true;
      _loadRestaurantData();
    }
  }

  Future<void> _loadRestaurantData() async {
    setState(() => _isLoading = true);
    try {
      final restaurant = await ref
          .read(restaurantServiceProvider)
          .getRestaurantById(widget.restaurantId!);
      if (restaurant != null && mounted) {
        _nameController.text = restaurant.name;
        _cityController.text = restaurant.city;
      }
    } catch (e) {
      if (mounted) {
        // If there's an error loading the restaurant, we'll just show an empty form.
        // In a real app, we might show an error message.
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final restaurant = RestaurantModel(
        id: widget.restaurantId ?? '',
        name: _nameController.text.trim(),
        city: _cityController.text.trim(),
      );

      if (widget.restaurantId == null) {
        // Adding new restaurant
        await ref.read(restaurantServiceProvider).addRestaurant(restaurant);
      } else {
        // Updating existing restaurant
        await ref.read(restaurantServiceProvider).updateRestaurant(restaurant);
      }

      if (mounted) {
        // Go back to the restaurant list screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save restaurant: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantId == null ? 'Add Restaurant' : 'Edit Restaurant'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Restaurant Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter restaurant name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveRestaurant,
                      child: Text(widget.restaurantId == null
                          ? 'Add Restaurant'
                          : 'Update Restaurant'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}