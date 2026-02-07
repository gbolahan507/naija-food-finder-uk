import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/restaurant_filter.dart';
import '../../data/providers/filter_provider.dart';
import '../../data/providers/restaurants_provider.dart';

class FilterModal extends ConsumerStatefulWidget {
  const FilterModal({super.key});

  @override
  ConsumerState<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<FilterModal> {
  late RestaurantFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    // Create a temporary copy of the current filter for editing
    _tempFilter = ref.read(restaurantFilterProvider);
  }

  void _updateDistance(double value) {
    setState(() {
      _tempFilter = _tempFilter.copyWith(maxDistance: value);
    });
  }

  void _toggleCuisine(String cuisine) {
    setState(() {
      final cuisines = List<String>.from(_tempFilter.selectedCuisines);
      if (cuisines.contains(cuisine)) {
        cuisines.remove(cuisine);
      } else {
        cuisines.add(cuisine);
      }
      _tempFilter = _tempFilter.copyWith(selectedCuisines: cuisines);
    });
  }

  void _toggleOpenNow() {
    setState(() {
      if (_tempFilter.isOpenNow == null) {
        _tempFilter = _tempFilter.copyWith(isOpenNow: true);
      } else if (_tempFilter.isOpenNow == true) {
        _tempFilter = _tempFilter.copyWith(clearOpenNow: true);
      } else {
        _tempFilter = _tempFilter.copyWith(clearOpenNow: true);
      }
    });
  }

  void _toggleDelivery() {
    setState(() {
      _tempFilter = _tempFilter.copyWith(hasDelivery: !_tempFilter.hasDelivery);
    });
  }

  void _toggleTakeaway() {
    setState(() {
      _tempFilter = _tempFilter.copyWith(hasTakeaway: !_tempFilter.hasTakeaway);
    });
  }

  void _togglePriceRange(PriceRange priceRange) {
    setState(() {
      final prices = List<PriceRange>.from(_tempFilter.selectedPriceRanges);
      if (prices.contains(priceRange)) {
        prices.remove(priceRange);
      } else {
        prices.add(priceRange);
      }
      _tempFilter = _tempFilter.copyWith(selectedPriceRanges: prices);
    });
  }

  void _updateMinimumRating(double? value) {
    setState(() {
      _tempFilter = _tempFilter.copyWith(
        minimumRating: value,
        clearMinimumRating: value == null,
      );
    });
  }

  void _updateCity(String? city) {
    setState(() {
      _tempFilter = _tempFilter.copyWith(
        selectedCity: city,
        clearSelectedCity: city == null,
      );
    });
  }

  void _clearFilters() {
    setState(() {
      _tempFilter = const RestaurantFilter.empty();
    });
  }

  void _applyFilters() {
    ref.read(restaurantFilterProvider.notifier).state = _tempFilter;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final availableCuisines = ref.watch(availableCuisinesProvider);
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Restaurants',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City Selection
                  _buildSectionTitle('City'),
                  const SizedBox(height: 8),
                  _buildCityDropdown(restaurantsAsync),
                  const SizedBox(height: 24),

                  // Distance Slider
                  _buildSectionTitle('Distance'),
                  const SizedBox(height: 8),
                  _buildDistanceSlider(),
                  const SizedBox(height: 24),

                  // Cuisine Selection
                  _buildSectionTitle('Cuisine Type'),
                  const SizedBox(height: 12),
                  _buildCuisineChips(availableCuisines),
                  const SizedBox(height: 24),

                  // Open Now Toggle
                  _buildSectionTitle('Availability'),
                  const SizedBox(height: 8),
                  _buildOpenNowToggle(),
                  const SizedBox(height: 24),

                  // Services
                  _buildSectionTitle('Services'),
                  const SizedBox(height: 8),
                  _buildServicesToggles(),
                  const SizedBox(height: 24),

                  // Price Range
                  _buildSectionTitle('Price Range'),
                  const SizedBox(height: 12),
                  _buildPriceRangeChips(),
                  const SizedBox(height: 24),

                  // Minimum Rating
                  _buildSectionTitle('Minimum Rating'),
                  const SizedBox(height: 12),
                  _buildRatingSelector(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primaryGreen),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Apply${_tempFilter.hasActiveFilters ? ' (${_tempFilter.activeFilterCount})' : ''}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDistanceSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Maximum distance'),
            Text(
              '${_tempFilter.maxDistance.toStringAsFixed(1)} miles',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        Slider(
          value: _tempFilter.maxDistance,
          min: 0,
          max: 10,
          divisions: 20,
          activeColor: AppColors.primaryGreen,
          thumbColor: AppColors.primaryGreen,
          onChanged: _updateDistance,
        ),
      ],
    );
  }

  Widget _buildCuisineChips(List<String> cuisines) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cuisines.map((cuisine) {
        final isSelected = _tempFilter.selectedCuisines.contains(cuisine);
        return FilterChip(
          label: Text(cuisine),
          selected: isSelected,
          onSelected: (_) => _toggleCuisine(cuisine),
          selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primaryGreen,
          side: BorderSide(
            color: isSelected ? AppColors.primaryGreen : Colors.grey[300]!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOpenNowToggle() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: SwitchListTile(
        title: const Text('Open Now'),
        subtitle: const Text('Show only restaurants that are currently open'),
        value: _tempFilter.isOpenNow ?? false,
        onChanged: (_) => _toggleOpenNow(),
        activeThumbColor: AppColors.primaryGreen,
        activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildServicesToggles() {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          child: SwitchListTile(
            title: const Text('Delivery Available'),
            subtitle: const Text('Offers delivery service'),
            value: _tempFilter.hasDelivery,
            onChanged: (_) => _toggleDelivery(),
            activeThumbColor: AppColors.primaryGreen,
            activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          child: SwitchListTile(
            title: const Text('Takeaway Available'),
            subtitle: const Text('Offers takeaway service'),
            value: _tempFilter.hasTakeaway,
            onChanged: (_) => _toggleTakeaway(),
            activeThumbColor: AppColors.primaryGreen,
            activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PriceRange.values.map((priceRange) {
        final isSelected = _tempFilter.selectedPriceRanges.contains(priceRange);
        return FilterChip(
          label: Text('${priceRange.symbol} ${priceRange.label}'),
          selected: isSelected,
          onSelected: (_) => _togglePriceRange(priceRange),
          selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primaryGreen,
          side: BorderSide(
            color: isSelected ? AppColors.primaryGreen : Colors.grey[300]!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Show restaurants rated'),
            Text(
              _tempFilter.minimumRating != null
                  ? '${_tempFilter.minimumRating!.toStringAsFixed(1)}+ stars'
                  : 'Any rating',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [null, 3.0, 3.5, 4.0, 4.5].map((rating) {
            final isSelected = _tempFilter.minimumRating == rating;
            return ChoiceChip(
              label: Text(rating == null ? 'Any' : '$rating+'),
              selected: isSelected,
              onSelected: (_) => _updateMinimumRating(rating),
              selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
              side: BorderSide(
                color: isSelected ? AppColors.primaryGreen : Colors.grey[300]!,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCityDropdown(AsyncValue<List<dynamic>> restaurantsAsync) {
    return restaurantsAsync.when(
      data: (restaurants) {
        final cityCounts = extractCitiesWithCounts(restaurants.cast());
        final cities = cityCounts.keys.toList()..sort();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _tempFilter.selectedCity != null
                  ? AppColors.primaryGreen
                  : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _tempFilter.selectedCity,
              isExpanded: true,
              hint: const Text('All Cities'),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Row(
                    children: [
                      const Icon(Icons.public, size: 18, color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      Text('All Cities (${restaurants.length})'),
                    ],
                  ),
                ),
                ...cities.map((city) {
                  final count = cityCounts[city] ?? 0;
                  return DropdownMenuItem<String?>(
                    value: city,
                    child: Row(
                      children: [
                        const Icon(Icons.location_city, size: 18, color: AppColors.primaryGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$city ($count)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) => _updateCity(value),
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading cities...'),
          ],
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Text('Could not load cities'),
      ),
    );
  }
}
