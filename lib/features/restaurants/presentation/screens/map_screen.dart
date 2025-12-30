import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/providers/restaurants_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadRestaurantMarkers();
  }

  Future<void> _loadRestaurantMarkers() async {
    setState(() => _isLoading = true);

    // Wait a bit for restaurants to load
    await Future.delayed(const Duration(milliseconds: 500));

    final restaurantsAsync = ref.read(restaurantsProvider);

    restaurantsAsync.whenData((restaurants) {
      final markers = restaurants.map((restaurant) {
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
        );
      }).toSet();

      setState(() {
        _markers.addAll(markers);
        _isLoading = false;
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _recenterMap() async {
    if (_mapController != null) {
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantsProvider);

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
                      Text(
                        '${restaurants.length} restaurants nearby',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
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
