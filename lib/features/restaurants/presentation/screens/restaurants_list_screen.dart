import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../widgets/restaurant_card.dart';
import '../../../../core/constants/app_colors.dart';

class RestaurantsListScreen extends StatelessWidget {
  const RestaurantsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurants = MockRestaurants.restaurants;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Naija Food Finder'),
            SizedBox(width: 8),
            Text(
              '🇳🇬🇬🇧',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filters
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.extraLightGrey,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', true),
                const SizedBox(width: 8),
                _buildFilterChip('Nigerian', false),
                const SizedBox(width: 8),
                _buildFilterChip('Delivery', false),
                const SizedBox(width: 8),
                _buildFilterChip('Open Now', false),
              ],
            ),
          ),

          // Restaurant List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return RestaurantCard(
                  restaurant: restaurant,
                  onTap: () {
                    // TODO: Navigate to restaurant details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tapped on ${restaurant.name}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryGreen : AppColors.mediumGrey,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.darkText,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }
}
