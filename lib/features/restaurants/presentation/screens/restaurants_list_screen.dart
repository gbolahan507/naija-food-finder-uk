import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/restaurants_provider.dart';
import '../../data/providers/filter_provider.dart';
import '../../data/models/restaurant_model.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/restaurant_card_skeleton.dart';
import '../widgets/filter_modal.dart';
import 'restaurant_details_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';

class RestaurantsListScreen extends ConsumerStatefulWidget {
  const RestaurantsListScreen({super.key});

  @override
  ConsumerState<RestaurantsListScreen> createState() =>
      _RestaurantsListScreenState();
}

class _RestaurantsListScreenState extends ConsumerState<RestaurantsListScreen> {
  String selectedSort = 'Distance';

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
          // Filter Button with Badge
          Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(restaurantFilterProvider);
              final activeCount = filter.activeFilterCount;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.9,
                          minChildSize: 0.5,
                          maxChildSize: 0.95,
                          builder: (context, scrollController) =>
                              const FilterModal(),
                        ),
                      );
                    },
                  ),
                  if (activeCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$activeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
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
      body: restaurantsAsync.when(
        data: (allRestaurants) {
          final restaurants = applySort(allRestaurants);

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
                  'Showing ${restaurants.length} ${restaurants.length == 1 ? 'restaurant' : 'restaurants'}',
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
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: 5,
          itemBuilder: (context, index) => const RestaurantCardSkeleton(),
        ),
        error: (error, stack) => ErrorState.custom(
          error: error.toString(),
          onRetry: _onRefresh,
        ),
      ),
    );
  }

  Widget _buildRestaurantList(List<Restaurant> restaurants) {
    if (restaurants.isEmpty) {
      return EmptyState.noResults();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return RestaurantCard(
            restaurant: restaurant,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailsScreen(
                    restaurant: restaurant,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
