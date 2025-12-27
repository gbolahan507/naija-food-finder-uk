import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/restaurants_provider.dart';
import '../../data/models/restaurant_model.dart';
import '../widgets/restaurant_card.dart';
import '../../../../core/constants/app_colors.dart';

class RestaurantsListScreen extends ConsumerStatefulWidget {
  const RestaurantsListScreen({super.key});

  @override
  ConsumerState<RestaurantsListScreen> createState() =>
      _RestaurantsListScreenState();
}

class _RestaurantsListScreenState extends ConsumerState<RestaurantsListScreen> {
  String selectedFilter = 'All';
  String selectedSort = 'Distance';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Restaurant> applyFilters(List<Restaurant> restaurants) {
    if (selectedFilter == 'All') return restaurants;

    if (selectedFilter == 'Nigerian') {
      return restaurants
          .where((r) => r.cuisineTypes.contains('Nigerian'))
          .toList();
    } else if (selectedFilter == 'Delivery') {
      return restaurants.where((r) => r.hasDelivery).toList();
    } else if (selectedFilter == 'Open Now') {
      return restaurants.where((r) => r.isOpenNow).toList();
    }

    return restaurants;
  }

  List<Restaurant> applySort(List<Restaurant> restaurants) {
    final sorted = List<Restaurant>.from(restaurants);

    switch (selectedSort) {
      case 'Distance':
        sorted.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'Rating':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Reviews':
        sorted.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }

    return sorted;
  }

  Future<void> _onRefresh() async {
    // Invalidate the providers to force a refresh
    ref.invalidate(filteredRestaurantsProvider);
    ref.invalidate(restaurantsProvider);

    // Small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(filteredRestaurantsProvider);

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
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                selectedSort = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Distance',
                child: Row(
                  children: [
                    Icon(
                      Icons.near_me,
                      color: selectedSort == 'Distance'
                          ? AppColors.primaryGreen
                          : AppColors.mediumGrey,
                    ),
                    const SizedBox(width: 8),
                    const Text('Sort by Distance'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Rating',
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: selectedSort == 'Rating'
                          ? AppColors.primaryGreen
                          : AppColors.mediumGrey,
                    ),
                    const SizedBox(width: 8),
                    const Text('Sort by Rating'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Name',
                child: Row(
                  children: [
                    Icon(
                      Icons.text_fields,
                      color: selectedSort == 'Name'
                          ? AppColors.primaryGreen
                          : AppColors.mediumGrey,
                    ),
                    const SizedBox(width: 8),
                    const Text('Sort by Name'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Reviews',
                child: Row(
                  children: [
                    Icon(
                      Icons.reviews,
                      color: selectedSort == 'Reviews'
                          ? AppColors.primaryGreen
                          : AppColors.mediumGrey,
                    ),
                    const SizedBox(width: 8),
                    const Text('Sort by Reviews'),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                ref.read(searchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search restaurants, cuisines...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryGreen,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
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

          // Restaurant List with loading/error states
          Expanded(
            child: restaurantsAsync.when(
              data: (allRestaurants) {
                var restaurants = applyFilters(allRestaurants);
                restaurants = applySort(restaurants);

                // Results count
                if (_searchController.text.isNotEmpty ||
                    selectedFilter != 'All') {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                      Expanded(
                        child: _buildRestaurantList(restaurants),
                      ),
                    ],
                  );
                }

                return _buildRestaurantList(restaurants);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantList(List<Restaurant> restaurants) {
    if (restaurants.isEmpty) {
      return const Center(
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
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return RestaurantCard(restaurant: restaurant);
        },
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
