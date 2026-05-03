class Restaurant {
  final String? id;
  final String name;
  final String city;
  final String? location;
  final String? cuisine;
  final String? priceRange;
  final String? hours;
  final String? features;
  final List<String>? signatureDishes;
  final List<dynamic>? userReviews;
  final String? sources;
  final double? rating;
  final String? category;
  final String? userId;
  final DateTime? createdAt;

  Restaurant({
    this.id,
    required this.name,
    required this.city,
    this.location,
    this.cuisine,
    this.priceRange,
    this.hours,
    this.features,
    this.signatureDishes,
    this.userReviews,
    this.sources,
    this.rating,
    this.category,
    this.userId,
    this.createdAt,
  });

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'location': location,
      'cuisine': cuisine,
      'price_range': priceRange,
      'hours': hours,
      'features': features,
      'signature_dishes': signatureDishes,
      'user_reviews': userReviews,
      'sources': sources,
      'rating': rating,
      'category': category,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create from JSON (from Supabase or assets)
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String?,
      name: json['name'] as String,
      city: json['city'] as String,
      location: json['location'] as String?,
      cuisine: json['cuisine'] as String?,
      priceRange: json['price_range'] as String? ?? json['priceRange'] as String?,
      hours: json['hours'] as String?,
      features: json['features'] as String?,
      signatureDishes: json['signature_dishes'] != null
          ? List<String>.from(json['signature_dishes'])
          : json['signatureDishes'] != null
              ? List<String>.from(json['signatureDishes'])
              : null,
      userReviews: json['user_reviews'] ?? json['userReviews'],
      sources: json['sources'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      category: json['category'] as String?,
      userId: json['user_id'] as String? ?? json['userId'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // Copy with method for immutability
  Restaurant copyWith({
    String? id,
    String? name,
    String? city,
    String? location,
    String? cuisine,
    String? priceRange,
    String? hours,
    String? features,
    List<String>? signatureDishes,
    List<dynamic>? userReviews,
    String? sources,
    double? rating,
    String? category,
    String? userId,
    DateTime? createdAt,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      location: location ?? this.location,
      cuisine: cuisine ?? this.cuisine,
      priceRange: priceRange ?? this.priceRange,
      hours: hours ?? this.hours,
      features: features ?? this.features,
      signatureDishes: signatureDishes ?? this.signatureDishes,
      userReviews: userReviews ?? this.userReviews,
      sources: sources ?? this.sources,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}