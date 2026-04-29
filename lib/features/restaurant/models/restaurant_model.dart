class Restaurant {
  final String? id;
  final String name;
  final String city;
  final String? userId;
  final DateTime? createdAt;

  Restaurant({
    this.id,
    required this.name,
    required this.city,
    this.userId,
    this.createdAt,
  });

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create from JSON (from Supabase)
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String?,
      name: json['name'] as String,
      city: json['city'] as String,
      userId: json['user_id'] as String?,
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
    String? userId,
    DateTime? createdAt,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}