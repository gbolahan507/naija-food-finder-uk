import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import 'google_places_service.dart';
import '../../features/restaurants/data/models/restaurant_model.dart';
import '../../features/restaurants/data/repositories/restaurants_repository.dart';

/// Service to sync restaurant data from Google Places API
class RestaurantSyncService {
  final GooglePlacesService _placesService;
  final RestaurantsRepository _repository;
  int _syncsThisSession = 0;

  RestaurantSyncService({
    required GooglePlacesService placesService,
    required RestaurantsRepository repository,
  })  : _placesService = placesService,
        _repository = repository;

  /// Check if we can perform more syncs this session
  bool get canSync => _syncsThisSession < ApiConfig.maxSyncsPerSession;

  /// Get count of syncs remaining
  int get syncsRemaining => ApiConfig.maxSyncsPerSession - _syncsThisSession;

  /// Sync a single restaurant with Google Places data
  Future<bool> syncRestaurant(Restaurant restaurant) async {
    if (!canSync) return false;

    final placeId = restaurant.placeId;
    if (placeId == null) return false;

    try {
      final details = await _placesService.getPlaceDetails(placeId);
      if (details == null) return false;

      // Prepare updates (only sync specific fields, preserve user data)
      final updates = <String, dynamic>{
        'rating': details.rating ?? restaurant.rating,
        'reviewCount': details.userRatingsTotal ?? restaurant.reviewCount,
        'phone': details.formattedPhoneNumber ?? restaurant.phone,
        'website': details.website,
        'isOpenNow': details.isOpenNow ?? restaurant.isOpenNow,
        'lastSyncedAt': DateTime.now().toIso8601String(),
      };

      // Update opening hours if available
      if (details.openingHours != null) {
        updates['openingHours'] = _convertOpeningHours(details.openingHours!);
      }

      await _repository.updateRestaurant(restaurant.id, updates);
      _syncsThisSession++;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sync all outdated restaurants
  Future<SyncResult> syncOutdatedRestaurants() async {
    if (!canSync) {
      return SyncResult(
        synced: 0,
        failed: 0,
        skipped: 0,
        message: 'Maximum syncs per session reached',
      );
    }

    try {
      final outdated = await _repository.getOutdatedRestaurants(
        ApiConfig.syncThreshold,
      );

      int synced = 0;
      int failed = 0;
      int skipped = 0;

      for (final restaurant in outdated) {
        if (!canSync) {
          skipped += outdated.length - synced - failed;
          break;
        }

        if (restaurant.placeId == null) {
          skipped++;
          continue;
        }

        final success = await syncRestaurant(restaurant);
        if (success) {
          synced++;
        } else {
          failed++;
        }
      }

      return SyncResult(
        synced: synced,
        failed: failed,
        skipped: skipped,
        message: _buildSyncMessage(synced, failed, skipped),
      );
    } catch (e) {
      return SyncResult(
        synced: 0,
        failed: 0,
        skipped: 0,
        message: 'Sync failed: ${e.toString()}',
      );
    }
  }

  /// Convert Places API opening hours to our model format
  List<Map<String, dynamic>> _convertOpeningHours(
    List<OpeningHoursPeriod> periods,
  ) {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final hoursMap = <int, Map<String, dynamic>>{};

    // Initialize all days as closed
    for (int i = 0; i < 7; i++) {
      hoursMap[i] = {
        'day': days[i],
        'isClosed': true,
        'openTime': null,
        'closeTime': null,
      };
    }

    // Fill in open days from periods
    for (final period in periods) {
      if (period.open != null) {
        final dayIndex = period.open!.day;
        final openTime = _formatTime(period.open!.time);
        final closeTime = period.close != null ? _formatTime(period.close!.time) : null;

        hoursMap[dayIndex] = {
          'day': days[dayIndex],
          'isClosed': false,
          'openTime': openTime,
          'closeTime': closeTime,
        };
      }
    }

    return hoursMap.values.toList();
  }

  /// Format time from HHMM to HH:MM
  String _formatTime(String? time) {
    if (time == null || time.length < 4) return '';
    return '${time.substring(0, 2)}:${time.substring(2, 4)}';
  }

  String _buildSyncMessage(int synced, int failed, int skipped) {
    final parts = <String>[];
    if (synced > 0) parts.add('$synced synced');
    if (failed > 0) parts.add('$failed failed');
    if (skipped > 0) parts.add('$skipped skipped');
    return parts.isEmpty ? 'No restaurants to sync' : parts.join(', ');
  }

  /// Reset the session sync counter
  void resetSessionCounter() {
    _syncsThisSession = 0;
  }
}

/// Result of a sync operation
class SyncResult {
  final int synced;
  final int failed;
  final int skipped;
  final String message;

  SyncResult({
    required this.synced,
    required this.failed,
    required this.skipped,
    required this.message,
  });

  bool get hasErrors => failed > 0;
  bool get hasSynced => synced > 0;
}

/// Provider for GooglePlacesService
final googlePlacesServiceProvider = Provider<GooglePlacesService>((ref) {
  final service = GooglePlacesService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for RestaurantSyncService
final restaurantSyncServiceProvider = Provider<RestaurantSyncService>((ref) {
  final placesService = ref.watch(googlePlacesServiceProvider);
  final repository = ref.watch(restaurantsRepositoryProvider);
  return RestaurantSyncService(
    placesService: placesService,
    repository: repository,
  );
});

/// Provider for the restaurants repository (re-exported for convenience)
final restaurantsRepositoryProvider = Provider<RestaurantsRepository>((ref) {
  return RestaurantsRepository();
});
