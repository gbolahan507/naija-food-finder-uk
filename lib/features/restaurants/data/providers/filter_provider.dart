import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/restaurant_filter.dart';
import '../models/restaurant_model.dart';

/// Provider for restaurant filters
final restaurantFilterProvider =
    StateProvider<RestaurantFilter>((ref) => const RestaurantFilter.empty());

/// Available cuisine types for filtering
final availableCuisinesProvider = Provider<List<String>>((ref) {
  return [
    'Nigerian',
    'West African',
    'Jollof',
    'Suya',
    'Amala',
    'Pounded Yam',
    'Egusi',
    'Afro-Caribbean',
    'Fusion',
  ];
});

/// Available cities provider - populated from restaurants
final availableCitiesProvider = StateProvider<List<String>>((ref) => []);

/// Helper to extract unique cities from restaurants
List<String> extractUniqueCities(List<Restaurant> restaurants) {
  final cities = restaurants
      .map((r) => r.city)
      .where((city) => city.isNotEmpty)
      .toSet()
      .toList();
  cities.sort();
  return cities;
}
