import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:naija_food_finder_uk/features/restaurants/data/repositories/favorites_repository.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';
import '../repositories/restaurants_repository.dart';
import '../repositories/reviews_repository.dart';

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

final filteredRestaurantsProvider = StreamProvider<List<Restaurant>>((ref) {
  final repository = ref.watch(restaurantsRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  return repository.searchRestaurants(searchQuery);
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
