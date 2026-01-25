import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/models/restaurant_filter.dart';
import '../../data/providers/restaurants_provider.dart';
import '../../data/providers/filter_provider.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/filter_modal.dart';
import 'restaurant_details_screen.dart';

// Search & Discover Screen - Full-featured search experience with 11+ features
// Provider for search query
final searchQueryStateProvider = StateProvider<String>((ref) => '');

// Provider for search history
final searchHistoryProvider = StateProvider<List<String>>((ref) => []);

// Provider for trending searches
final trendingSearchesProvider = Provider<List<String>>((ref) {
  return [
    'Jollof Rice',
    'Suya',
    'Egusi Soup',
    'Pounded Yam',
    'Pepper Soup',
    'Plantain',
  ];
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  bool _showSuggestions = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _showSuggestions = value.isNotEmpty;
    });

    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryStateProvider.notifier).state = value;
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  void _selectSearch(String query) {
    _searchController.text = query;
    setState(() {
      _showSuggestions = false;
    });
    _searchFocusNode.unfocus();

    // Add to search history
    final history = ref.read(searchHistoryProvider);
    if (!history.contains(query)) {
      ref.read(searchHistoryProvider.notifier).state = [query, ...history.take(9)];
    }

    ref.read(searchQueryStateProvider.notifier).state = query;
    ref.read(searchQueryProvider.notifier).state = query;
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _showSuggestions = false;
    });
    ref.read(searchQueryStateProvider.notifier).state = '';
    ref.read(searchQueryProvider.notifier).state = '';
  }

  void _toggleQuickFilter(String filterType) {
    final currentFilter = ref.read(restaurantFilterProvider);

    switch (filterType) {
      case 'openNow':
        ref.read(restaurantFilterProvider.notifier).state =
            currentFilter.copyWith(
              isOpenNow: currentFilter.isOpenNow == true ? null : true,
              clearOpenNow: currentFilter.isOpenNow == true,
            );
        break;
      case 'delivery':
        ref.read(restaurantFilterProvider.notifier).state =
            currentFilter.copyWith(hasDelivery: !currentFilter.hasDelivery);
        break;
      case 'nearMe':
        ref.read(restaurantFilterProvider.notifier).state =
            currentFilter.copyWith(maxDistance: currentFilter.maxDistance == 5.0 ? 50.0 : 5.0);
        break;
    }
  }

  void _togglePriceRange(PriceRange priceRange) {
    final currentFilter = ref.read(restaurantFilterProvider);
    final prices = List<PriceRange>.from(currentFilter.selectedPriceRanges);

    if (prices.contains(priceRange)) {
      prices.remove(priceRange);
    } else {
      prices.add(priceRange);
    }

    ref.read(restaurantFilterProvider.notifier).state =
        currentFilter.copyWith(selectedPriceRanges: prices);
  }

  void _selectCuisine(String cuisine) {
    final currentFilter = ref.read(restaurantFilterProvider);
    final cuisines = List<String>.from(currentFilter.selectedCuisines);

    if (cuisines.contains(cuisine)) {
      cuisines.remove(cuisine);
    } else {
      cuisines.clear();
      cuisines.add(cuisine);
    }

    ref.read(restaurantFilterProvider.notifier).state =
        currentFilter.copyWith(selectedCuisines: cuisines);
  }

  void _clearAllFilters() {
    ref.read(restaurantFilterProvider.notifier).state = const RestaurantFilter.empty();
    _clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryStateProvider);
    final restaurantsAsync = ref.watch(filteredRestaurantsProvider);
    final currentFilter = ref.watch(restaurantFilterProvider);
    final searchHistory = ref.watch(searchHistoryProvider);
    final trendingSearches = ref.watch(trendingSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 24),
            SizedBox(width: 8),
            Text('Search & Discover'),
          ],
        ),
        actions: [
          if (currentFilter != const RestaurantFilter.empty() || searchQuery.isNotEmpty)
            TextButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
              ),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          setState(() {
            _showSuggestions = false;
          });
        },
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Search Bar Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Main Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: _onSearchChanged,
                            onTap: () {
                              if (_searchController.text.isNotEmpty) {
                                setState(() {
                                  _showSuggestions = true;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Search restaurants, cuisines, dishes...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.primaryGreen,
                                size: 24,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: _clearSearch,
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick Filter Chips
                        _buildQuickFilterChips(currentFilter),
                      ],
                    ),
                  ),
                ),

                // Main Content
                if (searchQuery.isEmpty && currentFilter == const RestaurantFilter.empty())
                  ..._buildDiscoveryContent(restaurantsAsync, searchHistory, trendingSearches)
                else
                  _buildSearchResults(restaurantsAsync),
              ],
            ),

            // Search Suggestions Overlay
            if (_showSuggestions && searchQuery.isNotEmpty)
              _buildSearchSuggestions(restaurantsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilterChips(RestaurantFilter currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Open Now',
            icon: Icons.access_time,
            isSelected: currentFilter.isOpenNow == true,
            onTap: () => _toggleQuickFilter('openNow'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Delivery',
            icon: Icons.delivery_dining,
            isSelected: currentFilter.hasDelivery,
            onTap: () => _toggleQuickFilter('delivery'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Near Me',
            icon: Icons.near_me,
            isSelected: currentFilter.maxDistance == 5.0,
            onTap: () => _toggleQuickFilter('nearMe'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: '£',
            icon: Icons.attach_money,
            isSelected: currentFilter.selectedPriceRanges.contains(PriceRange.budget),
            onTap: () => _togglePriceRange(PriceRange.budget),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: '££',
            icon: Icons.attach_money,
            isSelected: currentFilter.selectedPriceRanges.contains(PriceRange.moderate),
            onTap: () => _togglePriceRange(PriceRange.moderate),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: '£££',
            icon: Icons.attach_money,
            isSelected: currentFilter.selectedPriceRanges.contains(PriceRange.expensive),
            onTap: () => _togglePriceRange(PriceRange.expensive),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'More Filters',
            icon: Icons.tune,
            isSelected: false,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const FilterModal(),
              );
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primaryGreen
              : isSelected
                  ? AppColors.primaryGreen
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary || isSelected ? Colors.white : AppColors.darkText,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary || isSelected ? Colors.white : AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDiscoveryContent(
    AsyncValue<List<Restaurant>> restaurantsAsync,
    List<String> searchHistory,
    List<String> trendingSearches,
  ) {
    return [
      // Trending Searches
      SliverToBoxAdapter(
        child: _buildSectionHeader('Trending Now', icon: Icons.trending_up),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trendingSearches.map((query) {
              return GestureDetector(
                onTap: () => _selectSearch(query),
                child: Chip(
                  avatar: const Icon(Icons.whatshot, size: 16, color: Colors.orange),
                  label: Text(query),
                  backgroundColor: Colors.orange.shade50,
                ),
              );
            }).toList(),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),

      // Browse by Cuisine
      SliverToBoxAdapter(
        child: _buildSectionHeader('Browse by Cuisine', icon: Icons.restaurant_menu),
      ),
      SliverToBoxAdapter(
        child: _buildCuisineGrid(restaurantsAsync),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),

      // Top Rated Restaurants
      SliverToBoxAdapter(
        child: _buildSectionHeader('Top Rated', icon: Icons.star),
      ),
      SliverToBoxAdapter(
        child: _buildTopRatedCarousel(restaurantsAsync),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }

  Widget _buildSectionHeader(String title, {IconData? icon, VoidCallback? onClear}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const Spacer(),
          if (onClear != null)
            TextButton(
              onPressed: onClear,
              child: const Text('Clear', style: TextStyle(fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildCuisineGrid(AsyncValue<List<Restaurant>> restaurantsAsync) {
    final cuisines = [
      {'name': 'Nigerian', 'icon': '🇳🇬', 'color': Colors.green},
      {'name': 'Jollof', 'icon': '🍚', 'color': Colors.orange},
      {'name': 'Suya', 'icon': '🍖', 'color': Colors.red},
      {'name': 'Egusi', 'icon': '🥘', 'color': Colors.brown},
      {'name': 'Pounded Yam', 'icon': '🍲', 'color': Colors.amber},
      {'name': 'Afro-Caribbean', 'icon': '🌴', 'color': Colors.teal},
    ];

    return restaurantsAsync.when(
      data: (restaurants) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: cuisines.length,
          itemBuilder: (context, index) {
            final cuisine = cuisines[index];
            final count = restaurants.where((r) =>
              r.cuisineTypes.any((c) => c.toLowerCase().contains(cuisine['name'].toString().toLowerCase()))
            ).length;

            return GestureDetector(
              onTap: () => _selectCuisine(cuisine['name'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: (cuisine['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (cuisine['color'] as Color).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cuisine['icon'] as String,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cuisine['name'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '$count places',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTopRatedCarousel(AsyncValue<List<Restaurant>> restaurantsAsync) {
    return restaurantsAsync.when(
      data: (restaurants) {
        final topRated = restaurants.where((r) => r.rating >= 4.5).toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));

        if (topRated.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: topRated.take(10).length,
            itemBuilder: (context, index) {
              return _buildCarouselCard(topRated[index]);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCarouselCard(Restaurant restaurant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailsScreen(restaurant: restaurant),
          ),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image - Takes about 60% of the card
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  restaurant.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.restaurant, size: 50, color: AppColors.mediumGrey),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Content - Takes about 40% of the card
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Rating and Distance
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${restaurant.rating}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '(${restaurant.reviewCount})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.lightText,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.location_on, size: 12, color: AppColors.primaryGreen),
                        Text(
                          '${restaurant.distance}mi',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                    // Status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: restaurant.isOpenNow
                                ? AppColors.primaryGreen.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            restaurant.isOpenNow ? 'Open' : 'Closed',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: restaurant.isOpenNow ? AppColors.primaryGreen : Colors.red,
                            ),
                          ),
                        ),
                        if (restaurant.hasDelivery) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.delivery_dining, size: 14, color: AppColors.primaryGreen),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(AsyncValue<List<Restaurant>> restaurantsAsync) {
    return restaurantsAsync.when(
      data: (restaurants) {
        if (restaurants.isEmpty) {
          return Positioned(
            top: 140,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'No restaurants found',
                style: TextStyle(color: AppColors.lightText),
              ),
            ),
          );
        }

        return Positioned(
          top: 140,
          left: 16,
          right: 16,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: restaurants.take(5).length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return ListTile(
                  onTap: () {
                    _searchFocusNode.unfocus();
                    setState(() {
                      _showSuggestions = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetailsScreen(restaurant: restaurant),
                      ),
                    );
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: restaurant.isOpenNow
                          ? AppColors.primaryGreen.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: restaurant.isOpenNow ? AppColors.primaryGreen : Colors.grey,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${restaurant.rating} ⭐ • ${restaurant.distance}mi',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  SliverToBoxAdapter _buildSearchResults(AsyncValue<List<Restaurant>> restaurantsAsync) {
    return SliverToBoxAdapter(
      child: restaurantsAsync.when(
        data: (restaurants) {
          if (restaurants.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: AppColors.mediumGrey),
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
                    'Try adjusting your filters or search terms',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.lightText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '${restaurants.length} restaurant${restaurants.length == 1 ? '' : 's'} found',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RestaurantCard(restaurant: restaurants[index]),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}
