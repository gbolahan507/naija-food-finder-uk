import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable empty state widget for consistent UI across the app
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Empty state for no search results
  factory EmptyState.noResults({
    String? searchQuery,
    VoidCallback? onClearFilters,
  }) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No restaurants found',
      message: searchQuery != null && searchQuery.isNotEmpty
          ? 'No results for "$searchQuery"\nTry different keywords or filters'
          : 'Try adjusting your search or filters',
      actionLabel: onClearFilters != null ? 'Clear Filters' : null,
      onAction: onClearFilters,
    );
  }

  /// Empty state for no favorites
  factory EmptyState.noFavorites({VoidCallback? onExplore}) {
    return EmptyState(
      icon: Icons.favorite_border,
      title: 'No favorites yet',
      message:
          'Start exploring and save your favorite\nNigerian restaurants here!',
      actionLabel: onExplore != null ? 'Explore Restaurants' : null,
      onAction: onExplore,
    );
  }

  /// Empty state for no reviews
  factory EmptyState.noReviews({VoidCallback? onWriteReview}) {
    return EmptyState(
      icon: Icons.rate_review_outlined,
      title: 'No reviews yet',
      message: 'Be the first to share your experience\nat this restaurant!',
      actionLabel: onWriteReview != null ? 'Write a Review' : null,
      onAction: onWriteReview,
    );
  }

  /// Empty state for connection issues
  factory EmptyState.offline({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'No connection',
      message: 'Please check your internet connection\nand try again',
      actionLabel: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.mediumGrey,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.lightText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
