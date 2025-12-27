import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

class RestaurantsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all restaurants
  Stream<List<Restaurant>> getRestaurants() {
    return _firestore
        .collection('restaurants')
        .snapshots()
        .map((snapshot) {
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

  // Search restaurants
  Stream<List<Restaurant>> searchRestaurants(String query) {
    return _firestore
        .collection('restaurants')
        .snapshots()
        .map((snapshot) {
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
}