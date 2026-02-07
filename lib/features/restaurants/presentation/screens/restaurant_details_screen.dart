import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/restaurant_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../data/providers/restaurants_provider.dart';
import '../widgets/review_card.dart';
import '../widgets/review_card_skeleton.dart';
import '../widgets/opening_hours_widget.dart';
import '../widgets/photo_gallery.dart';
import 'write_review_screen.dart';

class RestaurantDetailsScreen extends ConsumerWidget {
  final Restaurant restaurant;

  const RestaurantDetailsScreen({
    super.key,
    required this.restaurant,
  });

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('Could not launch $phoneUri');
    }
  }

  Future<void> _openDirections(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      return;
    }

    // Google Maps URL scheme
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );

    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch maps');
    }
  }

  Future<void> _openWebsite(String? website) async {
    if (website == null || website.isEmpty) {
      return;
    }

    final Uri websiteUri = Uri.parse(website);
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $websiteUri');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(restaurantReviewsProvider(restaurant.id));
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.value;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                restaurant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'restaurant-image-${restaurant.id}',
                    child: Image.network(
                      restaurant.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.lightGrey,
                          child: const Icon(
                            Icons.restaurant,
                            size: 80,
                            color: AppColors.mediumGrey,
                          ),
                        );
                      },
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating and Status
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.extraLightGrey,
                  child: Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.starYellow, size: 28),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${restaurant.reviewCount} reviews)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.lightText,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: restaurant.isOpenNow
                              ? AppColors.success
                              : AppColors.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          restaurant.isOpenNow ? 'Open Now' : 'Closed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Cuisine Types
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: restaurant.cuisineTypes.map((cuisine) {
                      return Chip(
                        label: Text(cuisine),
                        backgroundColor:
                            AppColors.primaryGreen.withValues(alpha: 0.1),
                        labelStyle: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Photo Gallery
                if (restaurant.photos != null && restaurant.photos!.isNotEmpty)
                  ...[
                    const SizedBox(height: 24),
                    PhotoGallery(
                      photos: restaurant.photos!,
                      heroTag: 'restaurant-photo-${restaurant.id}',
                    ),
                  ],

                const SizedBox(height: 24),

                // Location Section
                _buildSection(
                  icon: Icons.location_on,
                  iconColor: AppColors.primaryGreen,
                  title: 'Location',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.address,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.city,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_walk,
                            size: 18,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurant.distance.toStringAsFixed(1)} miles away',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 40, thickness: 1),

                // Services Section
                _buildSection(
                  icon: Icons.room_service,
                  iconColor: AppColors.info,
                  title: 'Services',
                  content: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (restaurant.hasDelivery)
                        _buildServiceBadge(
                          'Delivery Available',
                          Icons.delivery_dining,
                          AppColors.deliveryBadge,
                        ),
                      if (restaurant.hasTakeaway)
                        _buildServiceBadge(
                          'Takeaway Available',
                          Icons.shopping_bag,
                          AppColors.takeawayBadge,
                        ),
                    ],
                  ),
                ),

                const Divider(height: 40, thickness: 1),

                // Opening Hours Section
                if (restaurant.openingHours != null &&
                    restaurant.openingHours!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OpeningHoursWidget(
                      openingHours: restaurant.openingHours!,
                    ),
                  ),

                if (restaurant.openingHours != null &&
                    restaurant.openingHours!.isNotEmpty)
                  const Divider(height: 40, thickness: 1),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: restaurant.phone != null
                              ? () => _makePhoneCall(restaurant.phone)
                              : null,
                          icon: const Icon(Icons.phone),
                          label: Text(
                            restaurant.phone != null
                                ? 'Call Restaurant'
                                : 'No Phone Number',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: restaurant.latitude != null &&
                                  restaurant.longitude != null
                              ? () => _openDirections(
                                    restaurant.latitude,
                                    restaurant.longitude,
                                  )
                              : null,
                          icon: const Icon(Icons.directions),
                          label: Text(
                            restaurant.latitude != null &&
                                    restaurant.longitude != null
                                ? 'Get Directions'
                                : 'No Location Available',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            side: const BorderSide(
                              color: AppColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: restaurant.website != null
                              ? () => _openWebsite(restaurant.website)
                              : null,
                          icon: const Icon(Icons.language),
                          label: Text(
                            restaurant.website != null
                                ? 'Visit Website'
                                : 'No Website Available',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            side: const BorderSide(
                              color: AppColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _shareRestaurant(context);
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share Restaurant'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            side: const BorderSide(
                              color: AppColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 40, thickness: 1),

                // Reviews Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.reviews,
                              color: AppColors.primaryGreen, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (currentUser != null)
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WriteReviewScreen(
                                      restaurant: restaurant,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.rate_review, size: 18),
                              label: const Text('Write Review'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      reviewsAsync.when(
                        data: (reviews) {
                          if (reviews.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.rate_review_outlined,
                                      size: 48,
                                      color: AppColors.mediumGrey,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No reviews yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      currentUser != null
                                          ? 'Be the first to review!'
                                          : 'Sign in to write a review',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.lightText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: reviews.map((review) {
                              return ReviewCard(
                                review: review,
                                onEdit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WriteReviewScreen(
                                        restaurant: restaurant,
                                        existingReview: review,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Review'),
                                      content: const Text(
                                        'Are you sure you want to delete this review?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                                color: AppColors.error),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    try {
                                      await ref
                                          .read(reviewsRepositoryProvider)
                                          .deleteReview(review.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Review deleted'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Error: ${e.toString()}'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              );
                            }).toList(),
                          );
                        },
                        loading: () => Column(
                          children: List.generate(
                            3,
                            (index) => const ReviewCardSkeleton(),
                          ),
                        ),
                        error: (error, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'Error loading reviews: $error',
                              style: const TextStyle(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildServiceBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareRestaurant(BuildContext context) async {
    final shareText = '''
Check out ${restaurant.name}! 🇳🇬

${restaurant.cuisineTypes.join(' • ')}
⭐ ${restaurant.rating} (${restaurant.reviewCount} reviews)

📍 ${restaurant.address}, ${restaurant.city}
🚗 ${restaurant.distance.toStringAsFixed(1)} miles away

${restaurant.hasDelivery ? '✅ Delivery available' : ''}
${restaurant.hasTakeaway ? '✅ Takeaway available' : ''}
${restaurant.isOpenNow ? '🟢 Open now!' : '🔴 Currently closed'}

Found via Naija Food Finder UK 🇬🇧
  ''';

    try {
      final result =
          await SharePlus.instance.share(ShareParams(text: shareText));

      // Show success feedback if share was completed
      if (context.mounted && result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shared successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share at this time'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
