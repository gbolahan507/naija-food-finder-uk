import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naija_food_finder_uk/features/restaurants/data/providers/restaurants_provider.dart';
import '../../data/models/restaurant_model.dart';
import '../../../../core/constants/app_colors.dart';

class RestaurantCard extends ConsumerWidget {
  // ← Changed from StatelessWidget
  final Restaurant restaurant;
  final VoidCallback? onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ← Added WidgetRef ref
    final isFavoriteAsync = ref.watch(isFavoriteProvider(restaurant.id));

    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image with Hero animation
            Stack(
              children: [
                Hero(
                  tag: 'restaurant-image-${restaurant.id}',
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Image.network(
                      restaurant.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: AppColors.lightGrey,
                          child: const Icon(
                            Icons.restaurant,
                            size: 50,
                            color: AppColors.mediumGrey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Open/Closed Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: restaurant.isOpenNow
                          ? AppColors.success
                          : AppColors.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      restaurant.isOpenNow ? 'Open Now' : 'Closed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 8,
                  left: 8,
                  child: isFavoriteAsync.when(
                    data: (isFavorite) {
                      return GestureDetector(
                        onTap: () async {
                          debugPrint('❤️ Favorite button tapped for: ${restaurant.id}');
                          debugPrint('❤️ Current favorite state: $isFavorite');

                          final repository =
                              ref.read(favoritesRepositoryProvider);

                          try {
                            debugPrint('🔄 Calling toggleFavorite...');
                            await repository.toggleFavorite(restaurant.id, isFavorite);
                            debugPrint('✅ toggleFavorite completed successfully');

                            // Show feedback
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite
                                        ? 'Removed from favorites'
                                        : 'Added to favorites',
                                  ),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppColors.primaryGreen,
                                ),
                              );
                            }
                          } catch (e, stackTrace) {
                            debugPrint('❌ Error in toggleFavorite: $e');
                            debugPrint('❌ Stack trace: $stackTrace');
                            // Handle authentication error
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error: ${e.toString()}',
                                  ),
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color:
                                isFavorite ? Colors.red : AppColors.mediumGrey,
                            size: 24,
                          ),
                        ),
                      );
                    },
                    loading: () => Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: AppColors.mediumGrey,
                        size: 24,
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),

            // Restaurant Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        size: 18,
                        color: AppColors.starYellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Cuisine Types
                  Text(
                    restaurant.cuisineTypes.join(' • '),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.lightText,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Address and Distance
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${restaurant.distance}mi',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Delivery/Takeaway Badges
                  Row(
                    children: [
                      if (restaurant.hasDelivery)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.deliveryBadge.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.deliveryBadge,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Delivery',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.deliveryBadge,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (restaurant.hasDelivery && restaurant.hasTakeaway)
                        const SizedBox(width: 6),
                      if (restaurant.hasTakeaway)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.takeawayBadge.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.takeawayBadge,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Takeaway',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.takeawayBadge,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        '${restaurant.reviewCount} reviews',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
