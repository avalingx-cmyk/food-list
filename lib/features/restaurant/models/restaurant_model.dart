class UserReview {
  final String text;
  final double? rating;

  UserReview({required this.text, this.rating});

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      text: json['text'] as String? ?? '',
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (rating != null) 'rating': rating,
    };
  }
}

enum PriceCategory { budget, midRange, fineDining, unknown }

class RestaurantModel {
  final String id;
  final String name;
  final String city;
  final String? location;
  final String? cuisine;
  final String? priceRange;
  final String? hours;
  final String? features;
  final List<String> signatureDishes;
  final List<UserReview> userReviews;
  final String? sources;
  final double? rating;
  final String? category;
  final String? userId;
  final DateTime? createdAt;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.city,
    this.location,
    this.cuisine,
    this.priceRange,
    this.hours,
    this.features,
    this.signatureDishes = const [],
    this.userReviews = const [],
    this.sources,
    this.rating,
    this.category,
    this.userId,
    this.createdAt,
  });

  PriceCategory get priceCategory {
    if (category == null) return PriceCategory.unknown;
    final cat = category!.toLowerCase();
    if (cat.contains('budget') || cat.contains('street')) {
      return PriceCategory.budget;
    } else if (cat.contains('fine') || cat.contains('luxury')) {
      return PriceCategory.fineDining;
    } else if (cat.contains('mid') || cat.contains('international')) {
      return PriceCategory.midRange;
    }
    return PriceCategory.unknown;
  }

  double? get averageReviewRating {
    if (userReviews.isEmpty) return rating;
    final ratedReviews = userReviews.where((r) => r.rating != null).toList();
    if (ratedReviews.isEmpty) return rating;
    return ratedReviews.map((r) => r.rating!).reduce((a, b) => a + b) / ratedReviews.length;
  }

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      city: json['city'] as String,
      location: json['location'] as String?,
      cuisine: json['cuisine'] as String?,
      priceRange: json['price_range'] as String? ?? json['priceRange'] as String?,
      hours: json['hours'] as String?,
      features: json['features'] as String?,
      signatureDishes: json['signature_dishes'] != null
          ? List<String>.from(json['signature_dishes'] as List<dynamic>)
          : json['signatureDishes'] != null
              ? List<String>.from(json['signatureDishes'] as List<dynamic>)
              : [],
      userReviews: json['user_reviews'] != null
          ? (json['user_reviews'] as List<dynamic>)
              .map((r) => UserReview.fromJson(r as Map<String, dynamic>))
              .toList()
          : json['userReviews'] != null
              ? (json['userReviews'] as List<dynamic>)
                  .map((r) => UserReview.fromJson(r as Map<String, dynamic>))
                  .toList()
              : [],
      sources: json['sources'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      category: json['category'] as String?,
      userId: json['user_id'] as String? ?? json['userId'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'location': location,
      'cuisine': cuisine,
      'priceRange': priceRange,
      'hours': hours,
      'features': features,
      'signatureDishes': signatureDishes,
      'userReviews': userReviews.map((r) => r.toJson()).toList(),
      'sources': sources,
      'rating': rating,
      'category': category,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? city,
    String? location,
    String? cuisine,
    String? priceRange,
    String? hours,
    String? features,
    List<String>? signatureDishes,
    List<UserReview>? userReviews,
    String? sources,
    double? rating,
    String? category,
    String? userId,
    DateTime? createdAt,
  }) {
    return RestaurantModel(
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

typedef Restaurant = RestaurantModel;