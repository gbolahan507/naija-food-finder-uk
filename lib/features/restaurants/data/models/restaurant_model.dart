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
  final double? latitude;
  final double? longitude;

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
    this.latitude,
    this.longitude,
  });

  // Factory method to create from Firestore document
  factory Restaurant.fromFirestore(Map<String, dynamic> data, String id) {
    return Restaurant(
      id: id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
      distance: (data['distance'] as num?)?.toDouble() ?? 0.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      cuisineTypes: List<String>.from(data['cuisineTypes'] as List? ?? []),
      hasDelivery: data['hasDelivery'] as bool? ?? false,
      hasTakeaway: data['hasTakeaway'] as bool? ?? false,
      isOpenNow: data['isOpenNow'] as bool? ?? false,
      imageUrl: data['imageUrl'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  // Method to convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'distance': distance,
      'rating': rating,
      'reviewCount': reviewCount,
      'cuisineTypes': cuisineTypes,
      'hasDelivery': hasDelivery,
      'hasTakeaway': hasTakeaway,
      'isOpenNow': isOpenNow,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
