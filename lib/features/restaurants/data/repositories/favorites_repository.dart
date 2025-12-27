import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // For now, we'll use a simple guest user ID
  // Later, this will be replaced with actual user authentication
  final String _userId = 'guest_user';

  // Get user's favorite restaurant IDs
  Stream<List<String>> getFavorites() {
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
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(restaurantId)
        .delete();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String restaurantId, bool isFavorite) async {
    if (isFavorite) {
      await removeFavorite(restaurantId);
    } else {
      await addFavorite(restaurantId);
    }
  }

  // Check if restaurant is favorited
  Future<bool> isFavorite(String restaurantId) async {
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(restaurantId)
        .get();
    return doc.exists;
  }
}
