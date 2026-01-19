import 'restaurant_filter.dart';

// Opening hours for a single day
class DayHours {
  final String day;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  const DayHours({
    required this.day,
    this.openTime,
    this.closeTime,
    this.isClosed = false,
  });

  factory DayHours.fromMap(Map<String, dynamic> map) {
    return DayHours(
      day: map['day'] as String,
      openTime: map['openTime'] as String?,
      closeTime: map['closeTime'] as String?,
      isClosed: map['isClosed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }
}

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
  final List<DayHours>? openingHours;
  final String? phone;
  final PriceRange? priceRange;

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
    this.openingHours,
    this.phone,
    this.priceRange,
  });

  // Factory method to create from Firestore document
  factory Restaurant.fromFirestore(Map<String, dynamic> data, String id) {
    List<DayHours>? hours;
    if (data['openingHours'] != null) {
      hours = (data['openingHours'] as List)
          .map((item) => DayHours.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    // Parse price range from string
    PriceRange? priceRange;
    if (data['priceRange'] != null) {
      final priceRangeStr = data['priceRange'] as String;
      priceRange = PriceRange.values.firstWhere(
        (pr) => pr.symbol == priceRangeStr,
        orElse: () => PriceRange.moderate,
      );
    }

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
      openingHours: hours,
      phone: data['phone'] as String?,
      priceRange: priceRange,
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
      'openingHours': openingHours?.map((h) => h.toMap()).toList(),
      'phone': phone,
      'priceRange': priceRange?.symbol,
    };
  }
}
