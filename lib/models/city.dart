class City {
  final String id;
  final String name;
  final String imageAsset;
  final int restaurantCount;

  City({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.restaurantCount,
  });

  factory City.fromJson(String id, String name, int count) {
    return City(
      id: id,
      name: name,
      imageAsset: 'assets/images/${id}_city.jpg',
      restaurantCount: count,
    );
  }
}
