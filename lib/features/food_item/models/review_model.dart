class Review {
  final String? id;
  final String foodItemId;
  final int rating; // 1 to 5
  final String? comment;
  final String? userId;
  final DateTime? createdAt;

  Review({
    this.id,
    required this.foodItemId,
    required this.rating,
    this.comment,
    this.userId,
    this.createdAt,
  });

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'food_item_id': foodItemId,
      'rating': rating,
      'comment': comment,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create from JSON (from Supabase)
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String?,
      foodItemId: json['food_item_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // Copy with method for immutability
  Review copyWith({
    String? id,
    String? foodItemId,
    int? rating,
    String? comment,
    String? userId,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      foodItemId: foodItemId ?? this.foodItemId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}