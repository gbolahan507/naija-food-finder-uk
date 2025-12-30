import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/providers/restaurants_provider.dart';
import 'restaurant_details_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;

  // Default location: London, UK
  static const LatLng _defaultLocation = LatLng(51.5074, -0.1278);

  final Set<Marker> _markers = {};
  bool _isLoading = true;
  final Map<String, Restaurant> _restaurantMap = {};
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    // Markers will be loaded when restaurants data is available
  }

  void _loadRestaurantMarkers(List<Restaurant> restaurants) {
    setState(() => _isLoading = true);

    // Clear existing markers and restaurant map
    _markers.clear();
    _restaurantMap.clear();

    final markers = restaurants.map((restaurant) {
      // Store restaurant in map for later retrieval
      _restaurantMap[restaurant.id] = restaurant;

      return Marker(
        markerId: MarkerId(restaurant.id),
        position: LatLng(
          restaurant.latitude ?? 51.5074,
          restaurant.longitude ?? -0.1278,
        ),
        infoWindow: InfoWindow(
          title: restaurant.name,
          snippet: '${restaurant.rating} ⭐ • ${restaurant.distance}mi away',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
        onTap: () => _onMarkerTapped(restaurant.id),
      );
    }).toSet();

    setState(() {
      _markers.addAll(markers);
      _isLoading = false;
    });

    // Auto-recenter when markers change
    if (_markers.isNotEmpty && _mapController != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _recenterMap();
      });
    }
  }

  void _onMarkerTapped(String restaurantId) {
    final restaurant = _restaurantMap[restaurantId];
    if (restaurant != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantDetailsScreen(
            restaurant: restaurant,
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _recenterMap() async {
    if (_mapController != null) {
      // If we have markers, fit them all in view
      if (_markers.isNotEmpty) {
        final bounds = _calculateBounds();
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50),
        );
      } else {
        // Otherwise, center on default location
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            const CameraPosition(
              target: _defaultLocation,
              zoom: 12.0,
            ),
          ),
        );
      }
    }
  }

  LatLngBounds _calculateBounds() {
    double? minLat, maxLat, minLng, maxLng;

    for (final marker in _markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      if (minLat == null || lat < minLat) minLat = lat;
      if (maxLat == null || lat > maxLat) maxLat = lat;
      if (minLng == null || lng < minLng) minLng = lng;
      if (maxLng == null || lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat ?? 0, minLng ?? 0),
      northeast: LatLng(maxLat ?? 0, maxLng ?? 0),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(filteredRestaurantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map, color: Colors.white),
            SizedBox(width: 8),
            Text('Map View'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _recenterMap,
            tooltip: 'Recenter',
          ),
        ],
      ),
      body: restaurantsAsync.when(
        data: (restaurants) {
          // Update markers when filtered restaurants change
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadRestaurantMarkers(restaurants);
          });

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: _defaultLocation,
                  zoom: 12.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                mapType: _currentMapType,
              ),

              // Loading indicator
              if (_isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),

              // Restaurant count badge
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${restaurants.length} restaurants on map',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      // Search indicator
                      if (ref.watch(searchQueryProvider).isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search,
                                size: 12,
                                color: AppColors.primaryGreen,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Filtered',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Map type toggle button
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _currentMapType = _currentMapType == MapType.normal
                          ? MapType.satellite
                          : MapType.normal;
                    });
                  },
                  child: Icon(
                    _currentMapType == MapType.normal
                        ? Icons.satellite_alt
                        : Icons.map,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          );
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
                'Failed to load map',
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
    );
  }
}
