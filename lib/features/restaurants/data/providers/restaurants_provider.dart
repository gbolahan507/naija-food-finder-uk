import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:naija_food_finder_uk/features/restaurants/data/repositories/favorites_repository.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';
import '../repositories/restaurants_repository.dart';
import '../repositories/reviews_repository.dart';
import 'filter_provider.dart';

// Repository provider
final restaurantsRepositoryProvider = Provider<RestaurantsRepository>((ref) {
  return RestaurantsRepository();
});

// Restaurants stream provider
final restaurantsProvider = StreamProvider<List<Restaurant>>((ref) {
  final repository = ref.watch(restaurantsRepositoryProvider);
  return repository.getRestaurants();
});

// Search provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredRestaurantsProvider =
    StreamProvider<List<Restaurant>>((ref) async* {
  final repository = ref.watch(restaurantsRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final filter = ref.watch(restaurantFilterProvider);

  // Get restaurants from repository with search
  await for (final restaurants in repository.searchRestaurants(searchQuery)) {
    // Apply advanced filters
    var filtered = restaurants;

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
    // Include restaurants with matching price range OR null price range (not yet categorized)
    if (filter.selectedPriceRanges.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.priceRange == null ||
            filter.selectedPriceRanges.contains(r.priceRange);
      }).toList();
    }

    // Filter by minimum rating
    if (filter.minimumRating != null) {
      filtered = filtered.where((r) => r.rating >= filter.minimumRating!).toList();
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
