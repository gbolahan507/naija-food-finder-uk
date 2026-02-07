import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:naija_food_finder_uk/features/restaurants/data/repositories/favorites_repository.dart';
import '../../../../core/services/location_service.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';
import '../repositories/restaurants_repository.dart';
import '../repositories/reviews_repository.dart';
import 'filter_provider.dart';

// User location provider
final userLocationProvider = FutureProvider<LatLng?>((ref) async {
  return await LocationService.getCurrentLocation();
});

// Repository provider
final restaurantsRepositoryProvider = Provider<RestaurantsRepository>((ref) {
  return RestaurantsRepository();
});

// Restaurants stream provider (discovered restaurants only)
final restaurantsProvider = StreamProvider<List<Restaurant>>((ref) {
  final repository = ref.watch(restaurantsRepositoryProvider);
  return repository.getDiscoveredRestaurants();
});

// Search provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredRestaurantsProvider =
    StreamProvider<List<Restaurant>>((ref) async* {
  final repository = ref.watch(restaurantsRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final filter = ref.watch(restaurantFilterProvider);
  final userLocationAsync = ref.watch(userLocationProvider);

  // Get user location (may be null if permission denied)
  LatLng? userLocation;
  userLocationAsync.whenData((loc) => userLocation = loc);

  // Get restaurants from repository with search
  await for (final restaurants in repository.searchRestaurants(searchQuery)) {
    // Calculate distances from user location
    var restaurantsWithDistance = restaurants.map((r) {
      if (userLocation != null && r.latitude != null && r.longitude != null) {
        final distance = LocationService.calculateDistance(
          userLocation!.latitude,
          userLocation!.longitude,
          r.latitude!,
          r.longitude!,
        );
        return r.copyWith(distance: distance);
      }
      return r;
    }).toList();

    // Apply advanced filters
    var filtered = restaurantsWithDistance;

    // Filter by distance
    if (filter.maxDistance < 10.0) {
      filtered =
          filtered.where((r) => r.distance <= filter.maxDistance).toList();
    }

    // Filter by cuisines
    if (filter.selectedCuisines.isNotEmpty) {
      filtered = filtered.where((r) {
        return filter.selectedCuisines
            .any((cuisine) => r.cuisineTypes.contains(cuisine));
      }).toList();
    }

    // Filter by open status
    if (filter.isOpenNow != null) {
      if (filter.isOpenNow!) {
        filtered = filtered.where((r) => r.isOpenNow).toList();
      } else {
        filtered = filtered.where((r) => !r.isOpenNow).toList();
      }
    }

    // Filter by delivery
    if (filter.hasDelivery) {
      filtered = filtered.where((r) => r.hasDelivery).toList();
    }

    // Filter by takeaway
    if (filter.hasTakeaway) {
      filtered = filtered.where((r) => r.hasTakeaway).toList();
    }

    // Filter by price range
    if (filter.selectedPriceRanges.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.priceRange != null &&
            filter.selectedPriceRanges.contains(r.priceRange);
      }).toList();
    }

    // Filter by minimum rating
    if (filter.minimumRating != null) {
      filtered = filtered.where((r) => r.rating >= filter.minimumRating!).toList();
    }

    // Filter by city (using extracted city name)
    if (filter.selectedCity != null) {
      filtered = filtered.where((r) {
        final cityName = extractCityName(r.city);
        return cityName.toLowerCase() == filter.selectedCity!.toLowerCase();
      }).toList();
    }

    yield filtered;
  }
});

// Favorites repository provider
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

// Favorites stream provider
final favoritesProvider = StreamProvider<List<String>>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getFavorites();
});

// Check if specific restaurant is favorited
final isFavoriteProvider =
    StreamProvider.family<bool, String>((ref, restaurantId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.when(
    data: (favoriteIds) => Stream.value(favoriteIds.contains(restaurantId)),
    loading: () => Stream.value(false),
    error: (_, __) => Stream.value(false),
  );
});

// Reviews repository provider
final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository();
});

// Reviews stream provider for a specific restaurant
final restaurantReviewsProvider =
    StreamProvider.family<List<Review>, String>((ref, restaurantId) {
  final repository = ref.watch(reviewsRepositoryProvider);
  return repository.getRestaurantReviews(restaurantId);
});

// User's review for a specific restaurant
final userReviewProvider =
    StreamProvider.family<Review?, ({String restaurantId, String userId})>(
        (ref, params) {
  final repository = ref.watch(reviewsRepositoryProvider);
  return repository.getUserReviewForRestaurant(
      params.restaurantId, params.userId);
});
