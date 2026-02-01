import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/services/google_places_service.dart';
import '../models/restaurant_model.dart';
import '../repositories/restaurants_repository.dart';

/// Search mode for discovery
enum DiscoverySearchMode {
  nearMe,
  searchCity,
}

/// State for a single discovery result
class DiscoveryResult {
  final PlaceSearchResult place;
  final bool isSelected;
  final bool alreadyExists;
  final bool isAdding;

  DiscoveryResult({
    required this.place,
    this.isSelected = false,
    this.alreadyExists = false,
    this.isAdding = false,
  });

  DiscoveryResult copyWith({
    PlaceSearchResult? place,
    bool? isSelected,
    bool? alreadyExists,
    bool? isAdding,
  }) {
    return DiscoveryResult(
      place: place ?? this.place,
      isSelected: isSelected ?? this.isSelected,
      alreadyExists: alreadyExists ?? this.alreadyExists,
      isAdding: isAdding ?? this.isAdding,
    );
  }
}

/// State for the discovery feature
class DiscoveryState {
  final DiscoverySearchMode searchMode;
  final String cityQuery;
  final List<DiscoveryResult> results;
  final bool isLoading;
  final String? error;
  final bool hasSearched;

  DiscoveryState({
    this.searchMode = DiscoverySearchMode.nearMe,
    this.cityQuery = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.hasSearched = false,
  });

  DiscoveryState copyWith({
    DiscoverySearchMode? searchMode,
    String? cityQuery,
    List<DiscoveryResult>? results,
    bool? isLoading,
    String? error,
    bool? hasSearched,
  }) {
    return DiscoveryState(
      searchMode: searchMode ?? this.searchMode,
      cityQuery: cityQuery ?? this.cityQuery,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }

  int get selectedCount => results.where((r) => r.isSelected && !r.alreadyExists).length;
  List<DiscoveryResult> get selectableResults => results.where((r) => !r.alreadyExists).toList();
}

/// Notifier for discovery state
class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  final GooglePlacesService _placesService;
  final RestaurantsRepository _repository;

  DiscoveryNotifier({
    required GooglePlacesService placesService,
    required RestaurantsRepository repository,
  })  : _placesService = placesService,
        _repository = repository,
        super(DiscoveryState());

  void setSearchMode(DiscoverySearchMode mode) {
    state = state.copyWith(
      searchMode: mode,
      results: [],
      hasSearched: false,
      error: null,
    );
  }

  void setCityQuery(String query) {
    state = state.copyWith(cityQuery: query);
  }

  void toggleSelection(String placeId) {
    final newResults = state.results.map((result) {
      if (result.place.placeId == placeId && !result.alreadyExists) {
        return result.copyWith(isSelected: !result.isSelected);
      }
      return result;
    }).toList();
    state = state.copyWith(results: newResults);
  }

  void selectAll() {
    final newResults = state.results.map((result) {
      if (!result.alreadyExists) {
        return result.copyWith(isSelected: true);
      }
      return result;
    }).toList();
    state = state.copyWith(results: newResults);
  }

  void deselectAll() {
    final newResults = state.results.map((result) {
      return result.copyWith(isSelected: false);
    }).toList();
    state = state.copyWith(results: newResults);
  }

  Future<void> searchNearby(double lat, double lng) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final places = await _placesService.nearbySearch(lat: lat, lng: lng);
      final results = await _markExistingPlaces(places);
      state = state.copyWith(
        results: results,
        isLoading: false,
        hasSearched: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to search: ${e.toString()}',
        hasSearched: true,
      );
    }
  }

  Future<void> searchCity(String city) async {
    if (city.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter a city name');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final places = await _placesService.textSearch(query: city);
      final results = await _markExistingPlaces(places);
      state = state.copyWith(
        results: results,
        isLoading: false,
        hasSearched: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to search: ${e.toString()}',
        hasSearched: true,
      );
    }
  }

  Future<List<DiscoveryResult>> _markExistingPlaces(
    List<PlaceSearchResult> places,
  ) async {
    final results = <DiscoveryResult>[];

    for (final place in places) {
      // Check by placeId first
      bool exists = await _repository.existsByPlaceId(place.placeId);

      // If not found by placeId, try fuzzy matching
      if (!exists && place.address != null) {
        final existing = await _repository.findByNameAndAddress(
          place.name,
          place.address!,
        );
        exists = existing != null;
      }

      results.add(DiscoveryResult(
        place: place,
        alreadyExists: exists,
      ));
    }

    return results;
  }

  Future<AddRestaurantsResult> addSelectedRestaurants() async {
    final selectedResults = state.results
        .where((r) => r.isSelected && !r.alreadyExists)
        .toList();

    if (selectedResults.isEmpty) {
      return AddRestaurantsResult(added: 0, failed: 0, message: 'No restaurants selected');
    }

    int added = 0;
    int failed = 0;

    // Mark all selected as adding
    state = state.copyWith(
      results: state.results.map((r) {
        if (r.isSelected && !r.alreadyExists) {
          return r.copyWith(isAdding: true);
        }
        return r;
      }).toList(),
    );

    for (final result in selectedResults) {
      try {
        // Get full details from Places API
        final details = await _placesService.getPlaceDetails(result.place.placeId);

        // Create restaurant from place data
        final restaurant = Restaurant(
          id: '', // Firestore will generate this
          name: details?.name ?? result.place.name,
          address: details?.formattedAddress ?? result.place.address ?? '',
          city: _extractCity(details?.formattedAddress ?? result.place.address ?? ''),
          distance: 0.0, // Will be calculated based on user location
          rating: details?.rating ?? result.place.rating ?? 0.0,
          reviewCount: details?.userRatingsTotal ?? result.place.userRatingsTotal ?? 0,
          cuisineTypes: ['Nigerian', 'African'],
          hasDelivery: false, // Unknown from Places API
          hasTakeaway: false, // Unknown from Places API
          isOpenNow: details?.isOpenNow ?? result.place.isOpen ?? false,
          imageUrl: result.place.photoReference != null
              ? _placesService.getPhotoUrl(result.place.photoReference!)
              : '',
          latitude: details?.lat ?? result.place.lat,
          longitude: details?.lng ?? result.place.lng,
          phone: details?.formattedPhoneNumber,
          placeId: result.place.placeId,
          lastSyncedAt: DateTime.now(),
          source: RestaurantSource.placesApi,
          website: details?.website,
        );

        await _repository.addRestaurant(restaurant);
        added++;

        // Mark this one as done (now exists)
        state = state.copyWith(
          results: state.results.map((r) {
            if (r.place.placeId == result.place.placeId) {
              return r.copyWith(isAdding: false, alreadyExists: true, isSelected: false);
            }
            return r;
          }).toList(),
        );
      } catch (e) {
        failed++;
        // Mark as failed (stop adding indicator)
        state = state.copyWith(
          results: state.results.map((r) {
            if (r.place.placeId == result.place.placeId) {
              return r.copyWith(isAdding: false);
            }
            return r;
          }).toList(),
        );
      }
    }

    return AddRestaurantsResult(
      added: added,
      failed: failed,
      message: _buildAddMessage(added, failed),
    );
  }

  String _extractCity(String address) {
    // Try to extract city from UK address format
    // Typical format: "123 Street Name, City, Postcode, UK"
    final parts = address.split(',').map((p) => p.trim()).toList();

    if (parts.length >= 2) {
      // Second to last part is usually the city (before postcode/country)
      final cityPart = parts[parts.length - 2];
      // Check if it looks like a postcode (starts with letter then number)
      if (!RegExp(r'^[A-Z]{1,2}\d').hasMatch(cityPart.toUpperCase())) {
        return cityPart;
      }
      // If that's a postcode, try the one before
      if (parts.length >= 3) {
        return parts[parts.length - 3];
      }
    }

    return parts.isNotEmpty ? parts.first : 'Unknown';
  }

  String _buildAddMessage(int added, int failed) {
    if (added > 0 && failed == 0) {
      return '$added ${added == 1 ? 'restaurant' : 'restaurants'} added successfully';
    } else if (added > 0 && failed > 0) {
      return '$added added, $failed failed';
    } else if (failed > 0) {
      return 'Failed to add restaurants';
    }
    return 'No restaurants added';
  }

  void clearResults() {
    state = DiscoveryState();
  }
}

/// Result of adding restaurants
class AddRestaurantsResult {
  final int added;
  final int failed;
  final String message;

  AddRestaurantsResult({
    required this.added,
    required this.failed,
    required this.message,
  });

  bool get hasErrors => failed > 0;
  bool get hasAdded => added > 0;
}

/// Provider for GooglePlacesService
final googlePlacesServiceProvider = Provider<GooglePlacesService>((ref) {
  final service = GooglePlacesService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for DiscoveryNotifier
final discoveryProvider =
    StateNotifierProvider<DiscoveryNotifier, DiscoveryState>((ref) {
  final placesService = ref.watch(googlePlacesServiceProvider);
  final repository = RestaurantsRepository();
  return DiscoveryNotifier(
    placesService: placesService,
    repository: repository,
  );
});
