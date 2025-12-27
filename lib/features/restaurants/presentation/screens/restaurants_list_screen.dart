import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../data/models/restaurant_model.dart';
import '../widgets/restaurant_card.dart';
import '../../../../core/constants/app_colors.dart';

class RestaurantsListScreen extends StatefulWidget {
  const RestaurantsListScreen({super.key});

  @override
  State<RestaurantsListScreen> createState() => _RestaurantsListScreenState();
}

class _RestaurantsListScreenState extends State<RestaurantsListScreen> {
  String selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Restaurant> get filteredRestaurants {
    var restaurants = MockRestaurants.restaurants;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      restaurants = restaurants.where((restaurant) {
        final nameLower = restaurant.name.toLowerCase();
        final addressLower = restaurant.address.toLowerCase();
        final cityLower = restaurant.city.toLowerCase();
        final cuisineLower = restaurant.cuisineTypes.join(' ').toLowerCase();
        final searchLower = _searchQuery.toLowerCase();

        return nameLower.contains(searchLower) ||
            addressLower.contains(searchLower) ||
            cityLower.contains(searchLower) ||
            cuisineLower.contains(searchLower);
      }).toList();
    }

    // Apply category filter
    if (selectedFilter != 'All') {
      if (selectedFilter == 'Nigerian') {
        restaurants = restaurants
            .where((r) => r.cuisineTypes.contains('Nigerian'))
            .toList();
      } else if (selectedFilter == 'Delivery') {
        restaurants = restaurants.where((r) => r.hasDelivery).toList();
      } else if (selectedFilter == 'Open Now') {
        restaurants = restaurants.where((r) => r.isOpenNow).toList();
      }
    }

    return restaurants;
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = filteredRestaurants;

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
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search restaurants, cuisines...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryGreen,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.extraLightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.extraLightGrey,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', selectedFilter == 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('Nigerian', selectedFilter == 'Nigerian'),
                const SizedBox(width: 8),
                _buildFilterChip('Delivery', selectedFilter == 'Delivery'),
                const SizedBox(width: 8),
                _buildFilterChip('Open Now', selectedFilter == 'Open Now'),
              ],
            ),
          ),

          // Results count
          if (_searchQuery.isNotEmpty || selectedFilter != 'All')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.extraLightGrey,
              child: Text(
                '${restaurants.length} ${restaurants.length == 1 ? 'restaurant' : 'restaurants'} found',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Restaurant List
          Expanded(
            child: restaurants.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.mediumGrey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No restaurants found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return RestaurantCard(restaurant: restaurant);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
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
      ),
    );
  }
}
