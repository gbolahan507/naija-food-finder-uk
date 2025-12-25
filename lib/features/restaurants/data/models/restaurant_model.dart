class Restaurant {
  final String id;
  final String name;
  final String address;
  final String city;
  final double distance; // in miles
  final double rating;
  final int reviewCount;
  final List<String> cuisineTypes;
  final bool hasDelivery;
  final bool hasTakeaway;
  final bool isOpenNow;
  final String imageUrl;

  const Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.distance,
    required this.rating,
    required this.reviewCount,
    required this.cuisineTypes,
    this.hasDelivery = false,
    this.hasTakeaway = false,
    this.isOpenNow = false,
    required this.imageUrl,
  });
}
