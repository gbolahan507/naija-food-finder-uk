import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  FavoritesRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _firebaseAuth.currentUser?.uid;

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
    if (_userId == null) {
      throw Exception('User must be logged in to add favorites');
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(restaurantId)
        .set({
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove restaurant from favorites
  Future<void> removeFavorite(String restaurantId) async {
    if (_userId == null) {
      throw Exception('User must be logged in to remove favorites');
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(restaurantId)
        .delete();
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
