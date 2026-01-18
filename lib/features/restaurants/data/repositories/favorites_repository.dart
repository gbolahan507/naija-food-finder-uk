import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  FavoritesRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Get current user ID
  String? get _userId {
    final uid = _firebaseAuth.currentUser?.uid;
    debugPrint('🔑 FavoritesRepository - Current user ID: $uid');
    debugPrint('🔑 Current user email: ${_firebaseAuth.currentUser?.email}');
    return uid;
  }

  // Get user's favorite restaurant IDs
  Stream<List<String>> getFavorites() {
    // Return empty list if user is not authenticated
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // Add restaurant to favorites
  Future<void> addFavorite(String restaurantId) async {
    debugPrint('⭐ Adding favorite: $restaurantId');
    if (_userId == null) {
      debugPrint('❌ Cannot add favorite - user not logged in');
      throw Exception('User must be logged in to add favorites');
    }

    debugPrint('✅ User logged in, adding to Firestore...');
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(restaurantId)
          .set({
        'addedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Successfully added favorite to Firestore');
    } catch (e) {
      debugPrint('❌ Error adding favorite: $e');
      rethrow;
    }
  }

  // Remove restaurant from favorites
  Future<void> removeFavorite(String restaurantId) async {
    debugPrint('💔 Removing favorite: $restaurantId');
    if (_userId == null) {
      debugPrint('❌ Cannot remove favorite - user not logged in');
      throw Exception('User must be logged in to remove favorites');
    }

    debugPrint('✅ User logged in, removing from Firestore...');
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(restaurantId)
          .delete();
      debugPrint('✅ Successfully removed favorite from Firestore');
    } catch (e) {
      debugPrint('❌ Error removing favorite: $e');
      rethrow;
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String restaurantId, bool isFavorite) async {
    if (_userId == null) {
      throw Exception('User must be logged in to toggle favorites');
    }

    if (isFavorite) {
      await removeFavorite(restaurantId);
    } else {
      await addFavorite(restaurantId);
    }
  }

  // Check if restaurant is favorited
  Future<bool> isFavorite(String restaurantId) async {
    if (_userId == null) {
      return false;
    }

    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(restaurantId)
        .get();
    return doc.exists;
  }
}
