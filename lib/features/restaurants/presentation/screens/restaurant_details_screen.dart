import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/restaurant_model.dart';
import '../../../../core/constants/app_colors.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailsScreen({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
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
                  Image.network(
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
                    children: restaurant.cuisineTypes.map((cuisine) {
                      return Chip(
                        label: Text(cuisine),
                        backgroundColor:
                            AppColors.primaryGreen.withValues(alpha: 0.1),
                        labelStyle: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),

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
                            '${restaurant.distance} miles away',
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

                const Divider(height: 32),

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

                const Divider(height: 32),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement call functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Call restaurant')),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Call Restaurant'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement directions
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Get directions')),
                            );
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Get Directions'),
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
🚗 ${restaurant.distance} miles away

${restaurant.hasDelivery ? '✅ Delivery available' : ''}
${restaurant.hasTakeaway ? '✅ Takeaway available' : ''}
${restaurant.isOpenNow ? '🟢 Open now!' : '🔴 Currently closed'}

Found via Naija Food Finder UK 🇬🇧
  ''';

    try {
      await SharePlus.instance.share(ShareParams(text: shareText));
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
