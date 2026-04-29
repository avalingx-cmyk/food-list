import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_item_model.dart';
import '../services/food_item_service.dart';

class FoodItemFormScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  final String? foodId; // If null, we are adding; if provided, we are editing.

  const FoodItemFormScreen({
    Key? key,
    required this.restaurantId,
    this.foodId,
  }) : super(key: key);

  @override
  ConsumerState<FoodItemFormScreen> createState() => _FoodItemFormScreenState();
}

class _FoodItemFormScreenState extends ConsumerState<FoodItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _photoUrlController;
  late TextEditingController _reviewScoreController;
  bool _isLoading = false;
  FoodItem? _foodItem; // For editing

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _photoUrlController = TextEditingController();
    _reviewScoreController = TextEditingController();
    
    // If we have a foodId, load the food item for editing
    if (widget.foodId != null) {
      _loadFoodItemForEdit();
    }
  }

  Future<void> _loadFoodItemForEdit() async {
    try {
      final foodItemService = FoodItemService();
      final foodItems = await foodItemService.getFoodItemsByRestaurant(widget.restaurantId);
      final foodItem = foodItems.firstWhere((item) => item.id == widget.foodId, 
        orElse: () => FoodItem(id: widget.foodId, restaurantId: widget.restaurantId, name: '', price: 0));
      
      if (mounted) {
        setState(() {
          _foodItem = foodItem;
          _nameController.text = foodItem.name;
          _priceController.text = foodItem.price.toStringAsFixed(2);
          _photoUrlController.text = foodItem.photoUrl ?? '';
          _reviewScoreController.text = foodItem.reviewScore != null 
              ? foodItem.reviewScore.toStringAsFixed(1) 
              : '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load food item: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _photoUrlController.dispose();
    _reviewScoreController.dispose();
    super.dispose();
  }

  Future<void> _saveFoodItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final foodItem = FoodItem(
        id: widget.foodId, // Will be null for adding, have value for editing
        restaurantId: widget.restaurantId,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        photoUrl: _photoUrlController.text.trim().isEmpty
            ? null
            : _photoUrlController.text.trim(),
        reviewScore: _reviewScoreController.text.trim().isEmpty
            ? null
            : double.parse(_reviewScoreController.text),
      );

      if (widget.foodId == null) {
        // Adding new food item
        await ref.read(foodItemServiceProvider).addFoodItem(foodItem);
      } else {
        // Updating existing food item
        await ref.read(foodItemServiceProvider).updateFoodItem(foodItem);
      }

      if (mounted) {
        // Go back to the food list screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save food item: $e')),
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
        title: Text(widget.foodId == null ? 'Add Food Item' : 'Edit Food Item'),
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
                        labelText: 'Food Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter food name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (\$)',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _photoUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Photo URL (optional)',
                        border: OutlineInputBorder(),
                        hintText: 'https://example.com/food.jpg',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reviewScoreController,
                      decoration: const InputDecoration(
                        labelText: 'Review Score (0-5, optional)',
                        border: OutlineInputBorder(),
                        hintText: '4.5',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null; // optional
                        }
                        final score = double.tryParse(value);
                        if (score == null) {
                          return 'Please enter a valid number';
                        }
                        if (score < 0 || score > 5) {
                          return 'Score must be between 0 and 5';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveFoodItem,
                      child: Text(widget.foodId == null
                          ? 'Add Food Item'
                          : 'Update Food Item'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}