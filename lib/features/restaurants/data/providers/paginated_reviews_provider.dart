import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/review_model.dart';
import '../repositories/reviews_repository.dart';

/// State for paginated reviews
class PaginatedReviewsState {
  final List<Review> reviews;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final DocumentSnapshot? lastDocument;

  const PaginatedReviewsState({
    this.reviews = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.lastDocument,
  });

  PaginatedReviewsState copyWith({
    List<Review>? reviews,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    DocumentSnapshot? lastDocument,
  }) {
    return PaginatedReviewsState(
      reviews: reviews ?? this.reviews,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}

/// Provider for paginated reviews state
final paginatedReviewsProvider = StateProvider.family<PaginatedReviewsState, String>(
  (ref, restaurantId) => const PaginatedReviewsState(),
);

/// Provider for loading more reviews
final loadMoreReviewsProvider = FutureProvider.family<void, String>(
  (ref, restaurantId) async {
    final state = ref.read(paginatedReviewsProvider(restaurantId));
    if (state.isLoadingMore || !state.hasMore || state.lastDocument == null) {
      return;
    }

    // Set loading state
    ref.read(paginatedReviewsProvider(restaurantId).notifier).state =
        state.copyWith(isLoadingMore: true, error: null);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(state.lastDocument!)
          .limit(ReviewsRepository.reviewsPerPage)
          .get();

      final newReviews = snapshot.docs
          .map((doc) => Review.fromFirestore(doc.data(), doc.id))
          .toList();

      ref.read(paginatedReviewsProvider(restaurantId).notifier).state = state.copyWith(
        reviews: [...state.reviews, ...newReviews],
        isLoadingMore: false,
        hasMore: snapshot.docs.length >= ReviewsRepository.reviewsPerPage,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : state.lastDocument,
      );
    } catch (e) {
      ref.read(paginatedReviewsProvider(restaurantId).notifier).state =
          state.copyWith(isLoadingMore: false, error: e.toString());
    }
  },
);

/// Provider for initial reviews - loads first page automatically
final initialReviewsProvider = FutureProvider.family<void, String>(
  (ref, restaurantId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('createdAt', descending: true)
          .limit(ReviewsRepository.reviewsPerPage)
          .get();

      final reviews = snapshot.docs
          .map((doc) => Review.fromFirestore(doc.data(), doc.id))
          .toList();

      ref.read(paginatedReviewsProvider(restaurantId).notifier).state =
          PaginatedReviewsState(
        reviews: reviews,
        hasMore: snapshot.docs.length >= ReviewsRepository.reviewsPerPage,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      );
    } catch (e) {
      ref.read(paginatedReviewsProvider(restaurantId).notifier).state =
          PaginatedReviewsState(error: e.toString());
    }
  },
);
