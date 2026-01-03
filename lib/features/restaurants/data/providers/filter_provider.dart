import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/restaurant_filter.dart';

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
