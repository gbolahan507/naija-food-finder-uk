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

/// Extract just the city name from a full address/city field
/// e.g., "Birmingham B16 8UQ" -> "Birmingham"
String extractCityName(String cityField) {
  if (cityField.isEmpty) return '';

  // UK postcode pattern: 1-2 letters, 1-2 digits, optional space, digit, 2 letters
  final postcodePattern = RegExp(r'\s*[A-Z]{1,2}\d{1,2}\s*\d[A-Z]{2}\s*$', caseSensitive: false);

  // Remove postcode from the end
  var city = cityField.replaceAll(postcodePattern, '').trim();

  // Also handle cases like "47A Luton High St" - extract the city name
  // Common UK cities to look for
  final ukCities = [
    'London', 'Birmingham', 'Manchester', 'Leeds', 'Liverpool', 'Bristol',
    'Sheffield', 'Newcastle', 'Nottingham', 'Leicester', 'Coventry', 'Bradford',
    'Cardiff', 'Belfast', 'Edinburgh', 'Glasgow', 'Luton', 'Reading', 'Southampton',
    'Wolverhampton', 'Derby', 'Swansea', 'Preston', 'Milton Keynes', 'Northampton',
    'Norwich', 'Peterborough', 'Southend', 'Swindon', 'Huddersfield', 'Bournemouth',
    'Aberdeen', 'Dundee', 'Oxford', 'Cambridge', 'York', 'Portsmouth', 'Plymouth',
  ];

  // Check if any known city name is in the string
  for (final knownCity in ukCities) {
    if (city.toLowerCase().contains(knownCity.toLowerCase())) {
      return knownCity;
    }
  }

  // If no known city found, return the first word (likely the city)
  final parts = city.split(' ');
  if (parts.isNotEmpty) {
    // Skip numbers at the start (like "47A")
    for (final part in parts) {
      if (!RegExp(r'^\d').hasMatch(part) && part.length > 2) {
        return part;
      }
    }
  }

  return city;
}

/// Helper to extract unique cities from restaurants with counts
/// Returns a map of city name -> count
Map<String, int> extractCitiesWithCounts(List<Restaurant> restaurants) {
  final cityCounts = <String, int>{};

  for (final restaurant in restaurants) {
    final cityName = extractCityName(restaurant.city);
    if (cityName.isNotEmpty) {
      cityCounts[cityName] = (cityCounts[cityName] ?? 0) + 1;
    }
  }

  return cityCounts;
}

/// Helper to extract unique cities from restaurants (sorted list)
List<String> extractUniqueCities(List<Restaurant> restaurants) {
  final cityCounts = extractCitiesWithCounts(restaurants);
  final cities = cityCounts.keys.toList();
  cities.sort();
  return cities;
}
