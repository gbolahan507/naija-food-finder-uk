import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/restaurant_model.dart';
import '../repositories/restaurants_repository.dart';

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
