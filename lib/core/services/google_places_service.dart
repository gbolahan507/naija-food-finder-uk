import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Result from a places search with relevance scoring
class PlaceSearchResult {
  final String placeId;
  final String name;
  final String? address;
  final double? lat;
  final double? lng;
  final double? rating;
  final int? userRatingsTotal;
  final String? photoReference;
  final bool? isOpen;
  final List<String>? types;
  final int relevanceScore;

  PlaceSearchResult({
    required this.placeId,
    required this.name,
    this.address,
    this.lat,
    this.lng,
    this.rating,
    this.userRatingsTotal,
    this.photoReference,
    this.isOpen,
    this.types,
    this.relevanceScore = 0,
  });

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json, {int relevanceScore = 0}) {
    // Extract location
    double? lat;
    double? lng;
    if (json['geometry'] != null && json['geometry']['location'] != null) {
      lat = (json['geometry']['location']['lat'] as num?)?.toDouble();
      lng = (json['geometry']['location']['lng'] as num?)?.toDouble();
    }

    // Extract photo reference
    String? photoRef;
    if (json['photos'] != null && (json['photos'] as List).isNotEmpty) {
      photoRef = json['photos'][0]['photo_reference'] as String?;
    }

    // Extract open status
    bool? isOpen;
    if (json['opening_hours'] != null) {
      isOpen = json['opening_hours']['open_now'] as bool?;
    }

    return PlaceSearchResult(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      address: json['formatted_address'] as String? ?? json['vicinity'] as String?,
      lat: lat,
      lng: lng,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['user_ratings_total'] as int?,
      photoReference: photoRef,
      isOpen: isOpen,
      types: (json['types'] as List?)?.cast<String>(),
      relevanceScore: relevanceScore,
    );
  }
}

/// Detailed place information from Places API
class PlaceDetails {
  final String placeId;
  final String name;
  final String? formattedAddress;
  final String? formattedPhoneNumber;
  final String? website;
  final double? rating;
  final int? userRatingsTotal;
  final double? lat;
  final double? lng;
  final List<String>? types;
  final List<OpeningHoursPeriod>? openingHours;
  final bool? isOpenNow;
  final String? photoReference;
  final List<String>? photoReferences; // All photo references
  final int? priceLevel;

  PlaceDetails({
    required this.placeId,
    required this.name,
    this.formattedAddress,
    this.formattedPhoneNumber,
    this.website,
    this.rating,
    this.userRatingsTotal,
    this.lat,
    this.lng,
    this.types,
    this.openingHours,
    this.isOpenNow,
    this.photoReference,
    this.photoReferences,
    this.priceLevel,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    // Extract location
    double? lat;
    double? lng;
    if (json['geometry'] != null && json['geometry']['location'] != null) {
      lat = (json['geometry']['location']['lat'] as num?)?.toDouble();
      lng = (json['geometry']['location']['lng'] as num?)?.toDouble();
    }

    // Extract all photo references
    String? photoRef;
    List<String>? photoRefs;
    if (json['photos'] != null && (json['photos'] as List).isNotEmpty) {
      final photos = json['photos'] as List;
      photoRef = photos[0]['photo_reference'] as String?;
      photoRefs = photos
          .take(10) // Limit to 10 photos to control costs
          .map((p) => p['photo_reference'] as String)
          .toList();
    }

    // Extract opening hours
    List<OpeningHoursPeriod>? periods;
    bool? isOpenNow;
    if (json['opening_hours'] != null) {
      isOpenNow = json['opening_hours']['open_now'] as bool?;
      if (json['opening_hours']['periods'] != null) {
        periods = (json['opening_hours']['periods'] as List)
            .map((p) => OpeningHoursPeriod.fromJson(p as Map<String, dynamic>))
            .toList();
      }
    }

    return PlaceDetails(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      formattedAddress: json['formatted_address'] as String?,
      formattedPhoneNumber: json['formatted_phone_number'] as String?,
      website: json['website'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['user_ratings_total'] as int?,
      lat: lat,
      lng: lng,
      types: (json['types'] as List?)?.cast<String>(),
      openingHours: periods,
      isOpenNow: isOpenNow,
      photoReference: photoRef,
      photoReferences: photoRefs,
      priceLevel: json['price_level'] as int?,
    );
  }
}

/// Opening hours period
class OpeningHoursPeriod {
  final OpeningHoursTime? open;
  final OpeningHoursTime? close;

  OpeningHoursPeriod({this.open, this.close});

  factory OpeningHoursPeriod.fromJson(Map<String, dynamic> json) {
    return OpeningHoursPeriod(
      open: json['open'] != null
          ? OpeningHoursTime.fromJson(json['open'] as Map<String, dynamic>)
          : null,
      close: json['close'] != null
          ? OpeningHoursTime.fromJson(json['close'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Opening hours time
class OpeningHoursTime {
  final int day;
  final String time;

  OpeningHoursTime({required this.day, required this.time});

  factory OpeningHoursTime.fromJson(Map<String, dynamic> json) {
    return OpeningHoursTime(
      day: json['day'] as int,
      time: json['time'] as String,
    );
  }
}

/// Service for interacting with Google Places API
class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final http.Client _client;
  final Map<String, List<PlaceSearchResult>> _searchCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  GooglePlacesService({http.Client? client}) : _client = client ?? http.Client();

  /// Calculate relevance score for a place based on its name
  int _calculateRelevanceScore(String name) {
    final nameLower = name.toLowerCase();
    int score = 0;

    for (final entry in ApiConfig.relevanceKeywords.entries) {
      if (nameLower.contains(entry.key.toLowerCase())) {
        score += entry.value;
      }
    }

    return score;
  }

  /// Check if cache is still valid
  bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < ApiConfig.cacheExpiry;
  }

  /// Search for restaurants near a location
  Future<List<PlaceSearchResult>> nearbySearch({
    required double lat,
    required double lng,
    int radius = ApiConfig.defaultSearchRadius,
    List<String> keywords = const [],
  }) async {
    final cacheKey = 'nearby_${lat}_${lng}_$radius';

    if (_isCacheValid(cacheKey) && _searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    final results = <PlaceSearchResult>[];
    final seenPlaceIds = <String>{};

    // Search for each keyword
    final searchTerms = keywords.isNotEmpty ? keywords : ApiConfig.searchKeywords;

    for (final keyword in searchTerms) {
      try {
        final uri = Uri.parse('$_baseUrl/nearbysearch/json').replace(
          queryParameters: {
            'location': '$lat,$lng',
            'radius': radius.toString(),
            'keyword': keyword,
            'type': 'restaurant',
            'key': ApiConfig.googlePlacesApiKey,
            'language': ApiConfig.defaultLanguage,
          },
        );

        final response = await _client.get(uri);

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final status = data['status'] as String;

          if (status == 'OK' || status == 'ZERO_RESULTS') {
            final placesJson = data['results'] as List? ?? [];
            for (final placeJson in placesJson) {
              final placeId = placeJson['place_id'] as String;
              if (!seenPlaceIds.contains(placeId)) {
                seenPlaceIds.add(placeId);
                final score = _calculateRelevanceScore(placeJson['name'] as String);
                if (score >= ApiConfig.minimumRelevanceScore) {
                  results.add(PlaceSearchResult.fromJson(
                    placeJson as Map<String, dynamic>,
                    relevanceScore: score,
                  ));
                }
              }
            }
          }
        }
      } catch (e) {
        // Continue with other keywords if one fails
        continue;
      }
    }

    // Sort by relevance score (descending)
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    // Cache results
    _searchCache[cacheKey] = results;
    _cacheTimestamps[cacheKey] = DateTime.now();

    return results;
  }

  /// Search for restaurants by text query (city/area name)
  Future<List<PlaceSearchResult>> textSearch({
    required String query,
    String region = ApiConfig.defaultRegion,
  }) async {
    final cacheKey = 'text_${query}_$region';

    if (_isCacheValid(cacheKey) && _searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    final results = <PlaceSearchResult>[];
    final seenPlaceIds = <String>{};

    // Search for each keyword combined with the query
    for (final keyword in ApiConfig.searchKeywords) {
      try {
        final searchQuery = '$keyword $query';
        final uri = Uri.parse('$_baseUrl/textsearch/json').replace(
          queryParameters: {
            'query': searchQuery,
            'region': region,
            'type': 'restaurant',
            'key': ApiConfig.googlePlacesApiKey,
            'language': ApiConfig.defaultLanguage,
          },
        );

        final response = await _client.get(uri);

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final status = data['status'] as String;

          if (status == 'OK' || status == 'ZERO_RESULTS') {
            final placesJson = data['results'] as List? ?? [];
            for (final placeJson in placesJson) {
              final placeId = placeJson['place_id'] as String;
              if (!seenPlaceIds.contains(placeId)) {
                seenPlaceIds.add(placeId);
                final score = _calculateRelevanceScore(placeJson['name'] as String);
                if (score >= ApiConfig.minimumRelevanceScore) {
                  results.add(PlaceSearchResult.fromJson(
                    placeJson as Map<String, dynamic>,
                    relevanceScore: score,
                  ));
                }
              }
            }
          }
        }
      } catch (e) {
        // Continue with other keywords if one fails
        continue;
      }
    }

    // Sort by relevance score (descending)
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    // Cache results
    _searchCache[cacheKey] = results;
    _cacheTimestamps[cacheKey] = DateTime.now();

    return results;
  }

  /// Get detailed information about a specific place
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final uri = Uri.parse('$_baseUrl/details/json').replace(
        queryParameters: {
          'place_id': placeId,
          'fields': 'place_id,name,formatted_address,formatted_phone_number,'
              'website,rating,user_ratings_total,geometry,types,'
              'opening_hours,photos,price_level',
          'key': ApiConfig.googlePlacesApiKey,
          'language': ApiConfig.defaultLanguage,
        },
      );

      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String;

        if (status == 'OK' && data['result'] != null) {
          return PlaceDetails.fromJson(data['result'] as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get photo URL from photo reference
  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return '$_baseUrl/photo'
        '?maxwidth=$maxWidth'
        '&photo_reference=$photoReference'
        '&key=${ApiConfig.googlePlacesApiKey}';
  }

  /// Get all photo URLs from a list of photo references
  List<String> getPhotoUrls(List<String> photoReferences, {int maxWidth = 800}) {
    return photoReferences
        .map((ref) => getPhotoUrl(ref, maxWidth: maxWidth))
        .toList();
  }

  /// Clear the search cache
  void clearCache() {
    _searchCache.clear();
    _cacheTimestamps.clear();
  }

  /// Dispose of resources
  void dispose() {
    _client.close();
  }
}
