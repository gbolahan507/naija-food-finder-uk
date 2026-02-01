import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Default location: London, UK
  static const LatLng _defaultLocation = LatLng(51.5074, -0.1278);
  LatLng? _currentLocation;

  final Set<Marker> _markers = {};
  bool _isLoading = true;
  final Map<String, Restaurant> _restaurantMap = {};
  MapType _currentMapType = MapType.normal;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      debugPrint('=== REQUESTING LOCATION PERMISSION ===');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied forever');
        return;
      }

      // Get current position
      debugPrint('Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      debugPrint('Current location: ${position.latitude}, ${position.longitude}');

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Move camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation!,
              zoom: 14.0,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _loadRestaurantMarkers(List<Restaurant> restaurants) {
    debugPrint('=== LOADING RESTAURANT MARKERS ===');
    debugPrint('Number of restaurants: ${restaurants.length}');

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
          snippet:
              '${restaurant.rating} ⭐ • ${restaurant.distance.toStringAsFixed(1)}mi away${restaurant.isOpenNow ? ' • Open' : ' • Closed'}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          restaurant.isOpenNow
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
        onTap: () => _onMarkerTapped(restaurant.id),
      );
    }).toSet();

    setState(() {
      _markers.addAll(markers);
      _isLoading = false;
    });
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
    debugPrint('=== MAP CREATED ===');
    debugPrint('Map controller initialized successfully');

    // Move to current location if available
    if (_currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentLocation!,
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  Future<void> _recenterMap() async {
    if (_mapController != null) {
      // If we have current location, center on it
      if (_currentLocation != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation!,
              zoom: 14.0,
            ),
          ),
        );
      } else {
        // Otherwise, try to get current location
        await _getCurrentLocation();
        if (_currentLocation != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _currentLocation!,
                zoom: 14.0,
              ),
            ),
          );
        } else {
          // Fall back to default location
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
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Show/hide search results
    setState(() {
      _showSearchResults = value.isNotEmpty;
    });

    // Set new timer - only update search after 500ms of no typing
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  void _selectRestaurant(Restaurant restaurant) {
    // Hide search results
    setState(() {
      _showSearchResults = false;
    });

    // Center map on selected restaurant
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              restaurant.latitude ?? _defaultLocation.latitude,
              restaurant.longitude ?? _defaultLocation.longitude,
            ),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  Future<void> _fitMapToMarkers() async {
    if (_mapController == null || _markers.isEmpty) return;

    if (_markers.length == 1) {
      // If only one marker, center on it with good zoom
      final marker = _markers.first;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: marker.position,
            zoom: 16.0,
          ),
        ),
      );
    } else {
      // Multiple markers - fit bounds
      double minLat = _markers.first.position.latitude;
      double maxLat = _markers.first.position.latitude;
      double minLng = _markers.first.position.longitude;
      double maxLng = _markers.first.position.longitude;

      for (final marker in _markers) {
        final lat = marker.position.latitude;
        final lng = marker.position.longitude;

        if (lat < minLat) minLat = lat;
        if (lat > maxLat) maxLat = lat;
        if (lng < minLng) minLng = lng;
        if (lng > maxLng) maxLng = lng;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController?.dispose();
    _searchController.dispose();
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
          if (_markers.isEmpty || _isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadRestaurantMarkers(restaurants);
            });
          }

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentLocation ?? _defaultLocation,
                  zoom: 14.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                tiltGesturesEnabled: true,
                rotateGesturesEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
                mapType: _currentMapType,
                minMaxZoomPreference: const MinMaxZoomPreference(10.0, 20.0),
                buildingsEnabled: true,
                trafficEnabled: false,
                indoorViewEnabled: true,
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

              // Search bar and count
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search bar
                    Container(
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
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
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
                                      _showSearchResults = false;
                                      ref
                                          .read(searchQueryProvider.notifier)
                                          .state = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    // Search results dropdown
                    if (_showSearchResults && restaurants.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        constraints: const BoxConstraints(maxHeight: 300),
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
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: restaurants.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                          itemBuilder: (context, index) {
                            final restaurant = restaurants[index];
                            return ListTile(
                              onTap: () => _selectRestaurant(restaurant),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: restaurant.isOpenNow
                                      ? AppColors.primaryGreen
                                          .withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.restaurant,
                                  color: restaurant.isOpenNow
                                      ? AppColors.primaryGreen
                                      : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                restaurant.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${restaurant.rating} ⭐ • ${restaurant.distance.toStringAsFixed(1)}mi${restaurant.isOpenNow ? ' • Open' : ' • Closed'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.lightText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Icon(
                                Icons.location_on,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 8),
                    // Restaurant count badge - tappable to fit markers
                    if (!_showSearchResults)
                      GestureDetector(
                        onTap: _fitMapToMarkers,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.restaurant,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${restaurants.length} restaurants',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.center_focus_strong,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Zoom controls
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom In button
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      heroTag: 'zoom_in',
                      onPressed: () async {
                        if (_mapController != null) {
                          await _mapController!.animateCamera(
                            CameraUpdate.zoomIn(),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.add,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Zoom Out button
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      heroTag: 'zoom_out',
                      onPressed: () async {
                        if (_mapController != null) {
                          await _mapController!.animateCamera(
                            CameraUpdate.zoomOut(),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.remove,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Map type toggle button
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      heroTag: 'map_type',
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
                  ],
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
