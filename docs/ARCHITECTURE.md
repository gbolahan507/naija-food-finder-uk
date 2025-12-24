# Architecture Design

*Last updated: December 23/24, 2025*

## Overview

Naija Food Finder UK uses a **feature-first architecture** with **MVVM pattern** and **Riverpod** for state management.

## Architecture Pattern

### Feature-First Structure
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── api_endpoints.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── helpers.dart
│   └── router/
│       └── app_router.dart
│
├── features/
│   ├── restaurants/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── restaurant_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── restaurant_repository.dart
│   │   │   └── providers/
│   │   │       └── restaurant_provider.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── restaurants_list_screen.dart
│   │   │   │   └── restaurant_detail_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── restaurant_card.dart
│   │   │   │   └── restaurant_filters.dart
│   │   │   └── viewmodels/
│   │   │       └── restaurant_viewmodel.dart
│   │   └── domain/
│   │       └── entities/
│   │           └── restaurant.dart
│   │
│   ├── search/
│   │   └── [similar structure]
│   │
│   ├── map/
│   │   └── [similar structure]
│   │
│   ├── reviews/
│   │   └── [similar structure]
│   │
│   └── auth/
│       └── [similar structure]
│
└── shared/
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── loading_indicator.dart
    │   └── error_widget.dart
    └── models/
        └── api_response.dart
```

## State Management

**Choice:** Riverpod 2.x

**Why Riverpod:**
- ✅ Type-safe
- ✅ Compile-time safety
- ✅ Easy testing
- ✅ No BuildContext needed
- ✅ Industry standard

**Example Provider:**
```dart
final restaurantProvider = StateNotifierProvider<RestaurantNotifier, AsyncValue<List<Restaurant>>>((ref) {
  return RestaurantNotifier(ref.read(restaurantRepositoryProvider));
});
```

## Data Models

### Restaurant Model
```dart
class Restaurant {
  final String id;
  final String name;
  final String address;
  final GeoPoint location; // lat/lng
  final List<String> cuisineTypes;
  final double rating;
  final List<String> imageUrls;
  final Map<String, String> openingHours;
  final String phoneNumber;
  final bool hasDelivery;
  final bool hasTakeaway;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.cuisineTypes,
    this.rating = 0.0,
    this.imageUrls = const [],
    required this.openingHours,
    required this.phoneNumber,
    this.hasDelivery = false,
    this.hasTakeaway = false,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // fromJson, toJson, copyWith methods to be implemented
}
```

### Review Model
```dart
class Review {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final List<String> imageUrls;
  final DateTime createdAt;
  
  Review({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.imageUrls = const [],
    required this.createdAt,
  });
}
```

### User Model
```dart
class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final List<String> favoriteRestaurants;
  final DateTime createdAt;
  
  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.favoriteRestaurants = const [],
    required this.createdAt,
  });
}
```

## Firebase Structure

### Firestore Collections
```
restaurants/
  {restaurantId}/
    - id: string
    - name: string
    - address: string
    - location: GeoPoint
    - cuisineTypes: array
    - rating: number
    - imageUrls: array
    - openingHours: map
    - phoneNumber: string
    - hasDelivery: boolean
    - hasTakeaway: boolean
    - createdAt: timestamp
    - updatedAt: timestamp

reviews/
  {reviewId}/
    - id: string
    - restaurantId: string
    - userId: string
    - userName: string
    - rating: number
    - comment: string
    - imageUrls: array
    - createdAt: timestamp

users/
  {userId}/
    - id: string
    - email: string
    - displayName: string
    - photoUrl: string
    - favoriteRestaurants: array
    - createdAt: timestamp
```

## Navigation

**Router:** go_router package

**Routes:**
- `/` - Home/Restaurants List
- `/restaurant/:id` - Restaurant Details
- `/search` - Search Screen
- `/map` - Map View
- `/profile` - User Profile
- `/login` - Login Screen
- `/reviews/:restaurantId` - Reviews List

## Dependencies (Planned)
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  
  # Navigation
  go_router: ^12.0.0
  
  # Maps
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  
  # UI
  cached_network_image: ^3.3.0
  flutter_rating_bar: ^4.0.1
  
  # Utils
  intl: ^0.18.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

## Design Principles

1. **Separation of Concerns**: Each layer has clear responsibility
2. **Dependency Injection**: Using Riverpod providers
3. **Testability**: Easy to mock and test each layer
4. **Scalability**: Feature-first allows easy addition of new features
5. **Type Safety**: Leveraging Dart's type system

## Next Steps

- [ ] Setup Flutter project with this structure
- [ ] Implement core constants and theme
- [ ] Create base data models
- [ ] Setup Firebase configuration
- [ ] Implement first feature (restaurants list)

---

**Status:** ✅ Architecture Defined  
**Next:** Implementation Phase