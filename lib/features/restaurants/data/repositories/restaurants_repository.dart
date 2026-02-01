import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/restaurant_model.dart';

class RestaurantsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection names
  static const String curatedCollection = 'restaurants';
  static const String discoveredCollection = 'discovered_restaurants';

  // Get all restaurants (combines curated + discovered)
  Stream<List<Restaurant>> getRestaurants() {
    final curatedStream = _firestore.collection(curatedCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Restaurant.fromFirestore(doc.data(), doc.id);
      }).toList();
    });

    final discoveredStream = _firestore.collection(discoveredCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Restaurant.fromFirestore(doc.data(), doc.id);
      }).toList();
    });

    // Combine both streams
    return Rx.combineLatest2<List<Restaurant>, List<Restaurant>, List<Restaurant>>(
      curatedStream,
      discoveredStream,
      (curated, discovered) {
        final combined = <Restaurant>[];
        combined.addAll(curated);
        combined.addAll(discovered);
        return combined;
      },
    );
  }

  // Get only curated restaurants
  Stream<List<Restaurant>> getCuratedRestaurants() {
    return _firestore.collection(curatedCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Restaurant.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get only discovered restaurants
  Stream<List<Restaurant>> getDiscoveredRestaurants() {
    return _firestore.collection(discoveredCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Restaurant.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get single restaurant by ID
  Future<Restaurant?> getRestaurantById(String id) async {
    final doc = await _firestore.collection('restaurants').doc(id).get();
    if (doc.exists) {
      return Restaurant.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  // Search restaurants (discovered collection)
  Stream<List<Restaurant>> searchRestaurants(String query) {
    return _firestore.collection(discoveredCollection).snapshots().map((snapshot) {
      final restaurants = snapshot.docs.map((doc) {
        return Restaurant.fromFirestore(doc.data(), doc.id);
      }).toList();

      if (query.isEmpty) return restaurants;

      return restaurants.where((restaurant) {
        final searchLower = query.toLowerCase();
        return restaurant.name.toLowerCase().contains(searchLower) ||
            restaurant.address.toLowerCase().contains(searchLower) ||
            restaurant.city.toLowerCase().contains(searchLower) ||
            restaurant.cuisineTypes
                .join(' ')
                .toLowerCase()
                .contains(searchLower);
      }).toList();
    });
  }

  // Add a new restaurant
  Future<String> addRestaurant(Restaurant restaurant) async {
    final docRef = await _firestore.collection('restaurants').add(
      restaurant.toFirestore(),
    );
    return docRef.id;
  }

  // Update an existing restaurant
  Future<void> updateRestaurant(String id, Map<String, dynamic> updates) async {
    await _firestore.collection('restaurants').doc(id).update(updates);
  }

  // Find restaurant by Google Places ID
  Future<Restaurant?> findByPlaceId(String placeId) async {
    final snapshot = await _firestore
        .collection('restaurants')
        .where('placeId', isEqualTo: placeId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Restaurant.fromFirestore(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    }
    return null;
  }

  // Find restaurant by fuzzy name and address match (for legacy data without placeId)
  Future<Restaurant?> findByNameAndAddress(String name, String address) async {
    // Get all restaurants and do client-side fuzzy matching
    final snapshot = await _firestore.collection('restaurants').get();

    final nameLower = name.toLowerCase();
    final addressLower = address.toLowerCase();

    for (final doc in snapshot.docs) {
      final restaurant = Restaurant.fromFirestore(doc.data(), doc.id);
      final restaurantNameLower = restaurant.name.toLowerCase();
      final restaurantAddressLower = restaurant.address.toLowerCase();

      // Check for fuzzy match (contains or similar)
      final nameMatch = restaurantNameLower.contains(nameLower) ||
          nameLower.contains(restaurantNameLower) ||
          _levenshteinDistance(restaurantNameLower, nameLower) <= 3;

      final addressMatch = restaurantAddressLower.contains(addressLower) ||
          addressLower.contains(restaurantAddressLower) ||
          _similarityScore(restaurantAddressLower, addressLower) > 0.7;

      if (nameMatch && addressMatch) {
        return restaurant;
      }
    }
    return null;
  }

  // Get restaurants that haven't been synced recently
  Future<List<Restaurant>> getOutdatedRestaurants(Duration maxAge) async {
    final cutoffDate = DateTime.now().subtract(maxAge);
    final snapshot = await _firestore.collection('restaurants').get();

    final restaurants = snapshot.docs.map((doc) {
      return Restaurant.fromFirestore(doc.data(), doc.id);
    }).toList();

    // Filter restaurants that need syncing:
    // 1. Has a placeId (can be synced)
    // 2. Either never synced OR synced before cutoff date
    return restaurants.where((restaurant) {
      if (restaurant.placeId == null) return false;
      if (restaurant.lastSyncedAt == null) return true;
      return restaurant.lastSyncedAt!.isBefore(cutoffDate);
    }).toList();
  }

  // Check if a restaurant with given placeId already exists
  Future<bool> existsByPlaceId(String placeId) async {
    final restaurant = await findByPlaceId(placeId);
    return restaurant != null;
  }

  // Delete a restaurant
  Future<void> deleteRestaurant(String id) async {
    await _firestore.collection('restaurants').doc(id).delete();
  }

  // Levenshtein distance for fuzzy string matching
  int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        int cost = s1[i] == s2[j] ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }

      List<int> temp = v0;
      v0 = v1;
      v1 = temp;
    }

    return v0[s2.length];
  }

  // Simple similarity score between 0 and 1
  double _similarityScore(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final distance = _levenshteinDistance(s1, s2);
    final maxLength = s1.length > s2.length ? s1.length : s2.length;
    return 1.0 - (distance / maxLength);
  }
}
