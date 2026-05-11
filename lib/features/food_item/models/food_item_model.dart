class FoodItem {
  final String? id;
  final String restaurantId;
  final String name;
  final double price;
  final String? photoUrl;
  final double? reviewScore;
  final String? restaurantName;
  final String? city;
  final String? userId;
  final DateTime? createdAt;

  FoodItem({
    this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    this.photoUrl,
    this.reviewScore,
    this.restaurantName,
    this.city,
    this.userId,
    this.createdAt,
  });

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurantId,
      'name': name,
      'price': price,
      'photo_url': photoUrl,
      'review_score': reviewScore,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create from JSON (from Supabase)
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String?,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      photoUrl: json['photo_url'] as String?,
      reviewScore: json['review_score'] != null
          ? (json['review_score'] as num).toDouble()
          : null,
      restaurantName: json['restaurants']?['name'] as String?,
      city: json['restaurants']?['city'] as String?,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // Copy with method for immutability
  FoodItem copyWith({
    String? id,
    String? restaurantId,
    String? name,
    double? price,
    String? photoUrl,
    double? reviewScore,
    String? restaurantName,
    String? city,
    String? userId,
    DateTime? createdAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      price: price ?? this.price,
      photoUrl: photoUrl ?? this.photoUrl,
      reviewScore: reviewScore ?? this.reviewScore,
      restaurantName: restaurantName ?? this.restaurantName,
      city: city ?? this.city,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}