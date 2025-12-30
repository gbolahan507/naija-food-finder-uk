import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get reviews for a specific restaurant
  Stream<List<Review>> getRestaurantReviews(String restaurantId) {
    return _firestore
        .collection('reviews')
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Review.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Add a new review
  Future<void> addReview({
    required String restaurantId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required double rating,
    required String comment,
  }) async {
    await _firestore.collection('reviews').add({
      'restaurantId': restaurantId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': null,
    });
  }

  // Update an existing review
  Future<void> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    await _firestore.collection('reviews').doc(reviewId).update({
      'rating': rating,
      'comment': comment,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }

  // Get user's review for a specific restaurant (to check if they already reviewed)
  Stream<Review?> getUserReviewForRestaurant(
      String restaurantId, String userId) {
    return _firestore
        .collection('reviews')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Review.fromFirestore(snapshot.docs.first.data(), snapshot.docs.first.id);
    });
  }

  // Get average rating for a restaurant
  Future<double> getAverageRating(String restaurantId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('restaurantId', isEqualTo: restaurantId)
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    double sum = 0.0;
    for (var doc in snapshot.docs) {
      sum += (doc.data()['rating'] as num?)?.toDouble() ?? 0.0;
    }

    return sum / snapshot.docs.length;
  }

  // Get review count for a restaurant
  Future<int> getReviewCount(String restaurantId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('restaurantId', isEqualTo: restaurantId)
        .get();

    return snapshot.docs.length;
  }
}
