import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/location_service.dart';
import '../../data/providers/discovery_provider.dart';
import '../widgets/discovery_result_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final TextEditingController _cityController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _searchNearMe() async {
    setState(() => _isSearching = true);

    final location = await LocationService.getCurrentLocation();

    if (location == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get your location. Please enable location services.'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isSearching = false);
      }
      return;
    }

    await ref.read(discoveryProvider.notifier).searchNearby(
      location.latitude,
      location.longitude,
    );

    if (mounted) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _searchCity() async {
    final query = _cityController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a city name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSearching = true);
    await ref.read(discoveryProvider.notifier).searchCity(query);
    if (mounted) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _addSelectedRestaurants() async {
    final result = await ref.read(discoveryProvider.notifier).addSelectedRestaurants();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.hasErrors ? AppColors.warning : AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoveryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Restaurants'),
        actions: [
          if (state.selectedCount > 0)
            TextButton.icon(
              onPressed: _addSelectedRestaurants,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add (${state.selectedCount})',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search mode toggle
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.extraLightGrey,
            child: Column(
              children: [
                // Toggle buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildModeButton(
                        label: 'Near Me',
                        icon: Icons.my_location,
                        isSelected: state.searchMode == DiscoverySearchMode.nearMe,
                        onTap: () {
                          ref.read(discoveryProvider.notifier).setSearchMode(
                            DiscoverySearchMode.nearMe,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModeButton(
                        label: 'Search City',
                        icon: Icons.location_city,
                        isSelected: state.searchMode == DiscoverySearchMode.searchCity,
                        onTap: () {
                          ref.read(discoveryProvider.notifier).setSearchMode(
                            DiscoverySearchMode.searchCity,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search input/button
                if (state.searchMode == DiscoverySearchMode.nearMe)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSearching || state.isLoading ? null : _searchNearMe,
                      icon: _isSearching || state.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        _isSearching || state.isLoading
                            ? 'Searching...'
                            : 'Find Nigerian Restaurants Near Me',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            hintText: 'Enter city name (e.g., Manchester)',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (_) => _searchCity(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSearching || state.isLoading ? null : _searchCity,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSearching || state.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.search),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _buildResults(state),
          ),
        ],
      ),
      // Select all / deselect all FAB
      floatingActionButton: state.results.isNotEmpty && state.selectableResults.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                if (state.selectedCount == state.selectableResults.length) {
                  ref.read(discoveryProvider.notifier).deselectAll();
                } else {
                  ref.read(discoveryProvider.notifier).selectAll();
                }
              },
              icon: Icon(
                state.selectedCount == state.selectableResults.length
                    ? Icons.deselect
                    : Icons.select_all,
              ),
              label: Text(
                state.selectedCount == state.selectableResults.length
                    ? 'Deselect All'
                    : 'Select All',
              ),
              backgroundColor: AppColors.primaryGreen,
            )
          : null,
    );
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.mediumGrey,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.mediumGrey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(DiscoveryState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(height: 16),
            Text(
              'Searching for Nigerian & African restaurants...',
              style: TextStyle(color: AppColors.lightText),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (!state.hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.searchMode == DiscoverySearchMode.nearMe
                  ? Icons.location_searching
                  : Icons.search,
              size: 80,
              color: AppColors.mediumGrey,
            ),
            const SizedBox(height: 16),
            Text(
              state.searchMode == DiscoverySearchMode.nearMe
                  ? 'Tap the button above to find Nigerian\nrestaurants near your location'
                  : 'Enter a city name to discover\nNigerian restaurants',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state.results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 80,
              color: AppColors.mediumGrey,
            ),
            SizedBox(height: 16),
            Text(
              'No Nigerian restaurants found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching a different area',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.lightText,
              ),
            ),
          ],
        ),
      );
    }

    final newCount = state.selectableResults.length;
    final existingCount = state.results.length - newCount;

    return Column(
      children: [
        // Results summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.extraLightGrey,
          child: Text(
            'Found ${state.results.length} restaurants '
            '($newCount new, $existingCount already saved)',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.lightText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final result = state.results[index];
              return DiscoveryResultCard(
                result: result,
                onTap: () {
                  ref.read(discoveryProvider.notifier).toggleSelection(
                    result.place.placeId,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
