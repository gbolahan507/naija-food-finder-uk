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

/// Source of restaurant data
enum RestaurantSource {
  manual('manual'),
  placesApi('places_api'),
  userSubmitted('user_submitted');

  final String value;
  const RestaurantSource(this.value);

  static RestaurantSource fromString(String? value) {
    return RestaurantSource.values.firstWhere(
      (source) => source.value == value,
      orElse: () => RestaurantSource.manual,
    );
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
  // Google Places API fields
  final String? placeId;
  final DateTime? lastSyncedAt;
  final RestaurantSource? source;
  final String? website;

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
    this.placeId,
    this.lastSyncedAt,
    this.source,
    this.website,
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

    // Parse lastSyncedAt
    DateTime? lastSyncedAt;
    if (data['lastSyncedAt'] != null) {
      lastSyncedAt = DateTime.tryParse(data['lastSyncedAt'] as String);
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
      placeId: data['placeId'] as String?,
      lastSyncedAt: lastSyncedAt,
      source: RestaurantSource.fromString(data['source'] as String?),
      website: data['website'] as String?,
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
      'placeId': placeId,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'source': source?.value,
      'website': website,
    };
  }

  // CopyWith method for immutable updates
  Restaurant copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    double? distance,
    double? rating,
    int? reviewCount,
    List<String>? cuisineTypes,
    bool? hasDelivery,
    bool? hasTakeaway,
    bool? isOpenNow,
    String? imageUrl,
    double? latitude,
    double? longitude,
    List<DayHours>? openingHours,
    String? phone,
    PriceRange? priceRange,
    String? placeId,
    DateTime? lastSyncedAt,
    RestaurantSource? source,
    String? website,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      hasDelivery: hasDelivery ?? this.hasDelivery,
      hasTakeaway: hasTakeaway ?? this.hasTakeaway,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      openingHours: openingHours ?? this.openingHours,
      phone: phone ?? this.phone,
      priceRange: priceRange ?? this.priceRange,
      placeId: placeId ?? this.placeId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      source: source ?? this.source,
      website: website ?? this.website,
    );
  }
}
