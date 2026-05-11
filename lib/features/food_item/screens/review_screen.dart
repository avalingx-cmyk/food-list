import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../models/food_item_model.dart';
import '../providers/review_provider.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String foodItemId;
  final String foodItemName;

  const ReviewScreen({
    Key? key,
    required this.foodItemId,
    required this.foodItemName,
  }) : super(key: key);

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ratingController;
  late TextEditingController _commentController;
  bool _isLoading = false;
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _ratingController = TextEditingController();
    _commentController = TextEditingController();
    _loadReviews();
  }

  @override
  void dispose() {
    _ratingController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    try {
      final reviewService = ReviewService();
      final reviews = await reviewService.getReviewsForFoodItem(widget.foodItemId);
      if (mounted) {
        setState(() {
          _reviews = reviews;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reviews: $e')),
        );
      }
    }
  }

  Future<void> _addReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final review = Review(
        foodItemId: widget.foodItemId,
        rating: int.parse(_ratingController.text),
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      await ref.read(reviewServiceProvider).addReview(review);
      
      // Clear form
      _ratingController.clear();
      _commentController.clear();
      
      // Reload reviews
      await _loadReviews();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add review: $e')),
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
        title: Text('Reviews for ${widget.foodItemName}'),
      ),
      body: Column(
        children: [
          // Review form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _ratingController,
                    decoration: const InputDecoration(
                      labelText: 'Rating (1-5)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a rating';
                      }
                      final rating = int.tryParse(value);
                      if (rating == null) {
                        return 'Please enter a valid number';
                      }
                      if (rating < 1 || rating > 5) {
                        return 'Rating must be between 1 and 5';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comment (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'What did you think of this food?',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _addReview,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Review'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Reviews list
          Expanded(
            child: _reviews.isEmpty
                ? const Center(
                    child: Text('No reviews yet. Be the first to review!'),
                  )
                : ListView.builder(
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${review.rating}'),
                        ),
                        title: Text(review.comment ?? 'No comment'),
                        subtitle: Text(
                          'Rating: ${review.rating}/5 • ${review.createdAt?.toString() ?? ''}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}