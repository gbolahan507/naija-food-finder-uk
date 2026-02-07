import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'google_places_service.dart';
import '../../features/restaurants/data/models/restaurant_model.dart';
import '../../features/restaurants/data/models/restaurant_filter.dart';

/// Service to seed Firestore with restaurants from Google Places API
class RestaurantSeederService {
  final GooglePlacesService _placesService;
  final FirebaseFirestore _firestore;

  /// Collection name for discovered restaurants
  static const String collectionName = 'discovered_restaurants';

  RestaurantSeederService({
    required GooglePlacesService placesService,
    FirebaseFirestore? firestore,
  })  : _placesService = placesService,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Major UK cities to search for Nigerian/African restaurants
  static const List<String> ukCities = [
    'London',
    'Manchester',
    'Birmingham',
    'Leeds',
    'Liverpool',
    'Bristol',
    'Sheffield',
    'Newcastle',
    'Nottingham',
    'Leicester',
    'Coventry',
    'Bradford',
    'Cardiff',
    'Edinburgh',
    'Glasgow',
    'Reading',
    'Luton',
    'Croydon',
    'Wolverhampton',
    'Southampton',
  ];

  /// Delete all discovered restaurants from Firestore
  Future<int> deleteAllRestaurants() async {
    final collection = _firestore.collection(collectionName);
    final snapshots = await collection.get();

    int deleted = 0;
    final batch = _firestore.batch();

    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
      deleted++;
    }

    if (deleted > 0) {
      await batch.commit();
    }

    return deleted;
  }

  /// Seed restaurants from Google Places API
  Future<SeederResult> seedFromPlacesAPI({
    List<String>? cities,
    void Function(String status)? onProgress,
  }) async {
    final citiesToSearch = cities ?? ukCities;
    final seenPlaceIds = <String>{};
    int added = 0;
    int skipped = 0;
    int failed = 0;

    for (final city in citiesToSearch) {
      onProgress?.call('Searching $city...');

      try {
        // Search for restaurants in this city
        final results = await _placesService.textSearch(query: city);

        onProgress?.call('Found ${results.length} restaurants in $city');

        for (final place in results) {
          // Skip if we've already seen this place
          if (seenPlaceIds.contains(place.placeId)) {
            skipped++;
            continue;
          }
          seenPlaceIds.add(place.placeId);

          try {
            // Get full details
            final details = await _placesService.getPlaceDetails(place.placeId);

            // Get photo URLs
            List<String>? photos;
            if (details?.photoReferences != null && details!.photoReferences!.isNotEmpty) {
              photos = _placesService.getPhotoUrls(details.photoReferences!);
            }

            // Create restaurant object
            final restaurant = Restaurant(
              id: '', // Firestore will generate
              name: details?.name ?? place.name,
              address: details?.formattedAddress ?? place.address ?? '',
              city: _extractCity(details?.formattedAddress ?? place.address ?? '', city),
              distance: 0.0,
              rating: details?.rating ?? place.rating ?? 0.0,
              reviewCount: details?.userRatingsTotal ?? place.userRatingsTotal ?? 0,
              cuisineTypes: _determineCuisineTypes(place.name),
              hasDelivery: false,
              hasTakeaway: true,
              isOpenNow: details?.isOpenNow ?? place.isOpen ?? false,
              imageUrl: place.photoReference != null
                  ? _placesService.getPhotoUrl(place.photoReference!)
                  : '',
              latitude: details?.lat ?? place.lat,
              longitude: details?.lng ?? place.lng,
              phone: details?.formattedPhoneNumber,
              priceRange: _mapPriceLevel(details?.priceLevel),
              placeId: place.placeId,
              lastSyncedAt: DateTime.now(),
              source: RestaurantSource.placesApi,
              website: details?.website,
              photos: photos,
            );

            // Add to Firestore
            await _firestore.collection(collectionName).add(restaurant.toFirestore());
            added++;

            onProgress?.call('Added: ${restaurant.name}');

            // Small delay to avoid rate limiting
            await Future.delayed(const Duration(milliseconds: 100));
          } catch (e) {
            failed++;
          }
        }
      } catch (e) {
        onProgress?.call('Error searching $city: $e');
      }

      // Delay between cities to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return SeederResult(
      added: added,
      skipped: skipped,
      failed: failed,
      message: 'Seeding complete: $added added, $skipped duplicates, $failed failed',
    );
  }

  /// Full reset: delete all and seed fresh
  Future<SeederResult> resetAndSeed({
    List<String>? cities,
    void Function(String status)? onProgress,
  }) async {
    // Step 1: Delete all reviews (start fresh)
    onProgress?.call('Clearing old reviews...');
    final reviewsDeleted = await _deleteAllReviews();
    onProgress?.call('Deleted $reviewsDeleted reviews');

    // Step 2: Clear all favorites
    onProgress?.call('Clearing old favorites...');
    final favoritesDeleted = await _deleteAllFavorites();
    onProgress?.call('Deleted $favoritesDeleted favorites');

    // Step 3: Delete existing restaurants
    onProgress?.call('Deleting existing restaurants...');
    final deleted = await deleteAllRestaurants();
    onProgress?.call('Deleted $deleted restaurants');

    // Step 4: Seed new restaurants
    final result = await seedFromPlacesAPI(
      cities: cities,
      onProgress: onProgress,
    );

    return SeederResult(
      added: result.added,
      skipped: result.skipped,
      failed: result.failed,
      message: '${result.message}. Fresh start!',
    );
  }

  /// Delete all reviews
  Future<int> _deleteAllReviews() async {
    final snapshot = await _firestore.collection('reviews').get();
    int deleted = 0;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
      deleted++;
    }

    if (deleted > 0) {
      await batch.commit();
    }

    return deleted;
  }

  /// Delete all favorites from all users
  Future<int> _deleteAllFavorites() async {
    int deleted = 0;
    final usersSnapshot = await _firestore.collection('users').get();

    for (final userDoc in usersSnapshot.docs) {
      final favoritesSnapshot = await userDoc.reference.collection('favorites').get();

      if (favoritesSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final favDoc in favoritesSnapshot.docs) {
          batch.delete(favDoc.reference);
          deleted++;
        }
        await batch.commit();
      }
    }

    return deleted;
  }

  String _extractCity(String address, String fallbackCity) {
    // Try to extract city from UK address format
    final parts = address.split(',').map((p) => p.trim()).toList();

    if (parts.length >= 2) {
      // Look for the city in the address parts
      for (final part in parts) {
        if (ukCities.any((city) => part.toLowerCase().contains(city.toLowerCase()))) {
          return part;
        }
      }

      // Second to last part is usually the city
      final cityPart = parts[parts.length - 2];
      if (!RegExp(r'^[A-Z]{1,2}\d').hasMatch(cityPart.toUpperCase())) {
        return cityPart;
      }
      if (parts.length >= 3) {
        return parts[parts.length - 3];
      }
    }

    return fallbackCity;
  }

  List<String> _determineCuisineTypes(String name) {
    final nameLower = name.toLowerCase();
    final cuisines = <String>['African'];

    if (nameLower.contains('nigeria') || nameLower.contains('naija')) {
      cuisines.insert(0, 'Nigerian');
    }
    if (nameLower.contains('ghana')) {
      cuisines.add('Ghanaian');
    }
    if (nameLower.contains('west african')) {
      cuisines.add('West African');
    }
    if (nameLower.contains('jollof') || nameLower.contains('suya')) {
      if (!cuisines.contains('Nigerian')) {
        cuisines.insert(0, 'Nigerian');
      }
    }

    return cuisines;
  }

  PriceRange? _mapPriceLevel(int? priceLevel) {
    if (priceLevel == null) return null;
    switch (priceLevel) {
      case 0:
      case 1:
        return PriceRange.budget;
      case 2:
        return PriceRange.moderate;
      case 3:
        return PriceRange.expensive;
      case 4:
        return PriceRange.luxury;
      default:
        return PriceRange.moderate;
    }
  }
}

/// Result of seeding operation
class SeederResult {
  final int added;
  final int skipped;
  final int failed;
  final String message;

  SeederResult({
    required this.added,
    required this.skipped,
    required this.failed,
    required this.message,
  });
}

/// Provider for RestaurantSeederService
final restaurantSeederServiceProvider = Provider<RestaurantSeederService>((ref) {
  final placesService = GooglePlacesService();
  ref.onDispose(() => placesService.dispose());
  return RestaurantSeederService(placesService: placesService);
});
