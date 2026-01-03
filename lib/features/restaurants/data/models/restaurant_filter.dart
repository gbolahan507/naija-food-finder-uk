import 'package:equatable/equatable.dart';

/// Model class for restaurant filtering
class RestaurantFilter extends Equatable {
  final double maxDistance; // in miles
  final List<String> selectedCuisines;
  final bool? isOpenNow; // null = don't filter, true = open only, false = closed only
  final bool hasDelivery;
  final bool hasTakeaway;

  const RestaurantFilter({
    this.maxDistance = 10.0,
    this.selectedCuisines = const [],
    this.isOpenNow,
    this.hasDelivery = false,
    this.hasTakeaway = false,
  });

  /// Create an empty filter (no filters applied)
  const RestaurantFilter.empty()
      : maxDistance = 10.0,
        selectedCuisines = const [],
        isOpenNow = null,
        hasDelivery = false,
        hasTakeaway = false;

  /// Check if any filters are active
  bool get hasActiveFilters {
    return maxDistance < 10.0 ||
        selectedCuisines.isNotEmpty ||
        isOpenNow != null ||
        hasDelivery ||
        hasTakeaway;
  }

  /// Count the number of active filters
  int get activeFilterCount {
    int count = 0;
    if (maxDistance < 10.0) count++;
    if (selectedCuisines.isNotEmpty) count++;
    if (isOpenNow != null) count++;
    if (hasDelivery) count++;
    if (hasTakeaway) count++;
    return count;
  }

  /// Copy with method for immutable updates
  RestaurantFilter copyWith({
    double? maxDistance,
    List<String>? selectedCuisines,
    bool? isOpenNow,
    bool? hasDelivery,
    bool? hasTakeaway,
    bool clearOpenNow = false,
  }) {
    return RestaurantFilter(
      maxDistance: maxDistance ?? this.maxDistance,
      selectedCuisines: selectedCuisines ?? this.selectedCuisines,
      isOpenNow: clearOpenNow ? null : (isOpenNow ?? this.isOpenNow),
      hasDelivery: hasDelivery ?? this.hasDelivery,
      hasTakeaway: hasTakeaway ?? this.hasTakeaway,
    );
  }

  @override
  List<Object?> get props => [
        maxDistance,
        selectedCuisines,
        isOpenNow,
        hasDelivery,
        hasTakeaway,
      ];
}
