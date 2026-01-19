import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service to add additional restaurants to Firestore
class AdditionalRestaurantsInitializer {
  final FirebaseFirestore _firestore;

  AdditionalRestaurantsInitializer({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Add 7 new restaurants from Luton, Hatfield, and Stevenage areas
  Future<void> addAdditionalRestaurants() async {
    try {
      debugPrint('📊 Adding additional restaurants from Luton, Hatfield, Stevenage...');

      final restaurants = [
        {
          'id': 'dudu-bar-luton',
          'name': 'Dudu Bar Nigerian Restaurant and Lounge',
          'address': '21 High Town Rd',
          'city': 'Luton',
          'distance': 25.5,
          'latitude': 51.8847,
          'longitude': -0.4175,
          'rating': 4.2,
          'reviewCount': 66,
          'cuisineTypes': ['Nigerian', 'African'],
          'hasDelivery': true,
          'hasTakeaway': true,
          'isOpenNow': true,
          'imageUrl': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&q=80',
          'phone': '+44 7542 898100',
          'priceRange': '££',
          'openingHours': [
            {'day': 'Monday', 'openTime': '13:00', 'closeTime': '23:00'},
            {'day': 'Tuesday', 'openTime': '13:00', 'closeTime': '23:00'},
            {'day': 'Wednesday', 'openTime': '13:00', 'closeTime': '23:00'},
            {'day': 'Thursday', 'openTime': '13:00', 'closeTime': '23:00'},
            {'day': 'Friday', 'openTime': '13:00', 'closeTime': '02:00'},
            {'day': 'Saturday', 'openTime': '13:00', 'closeTime': '02:00'},
            {'day': 'Sunday', 'openTime': '13:00', 'closeTime': '22:00'},
          ],
        },
        {
          'id': 'pades-lounge-luton',
          'name': 'Pades Lounge African',
          'address': '39 Wellington Street',
          'city': 'Luton',
          'distance': 25.8,
          'latitude': 51.8797,
          'longitude': -0.4152,
          'rating': 4.0,
          'reviewCount': 120,
          'cuisineTypes': ['Nigerian', 'African'],
          'hasDelivery': true,
          'hasTakeaway': true,
          'isOpenNow': false,
          'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
          'phone': '+44 1582 518158',
          'priceRange': '££',
          'openingHours': [
            {'day': 'Monday', 'openTime': '12:30', 'closeTime': '00:00'},
            {'day': 'Tuesday', 'openTime': '12:30', 'closeTime': '00:00'},
            {'day': 'Wednesday', 'openTime': '12:30', 'closeTime': '00:00'},
            {'day': 'Thursday', 'openTime': '12:30', 'closeTime': '00:00'},
            {'day': 'Friday', 'openTime': '12:00', 'closeTime': '03:00'},
            {'day': 'Saturday', 'openTime': '13:00', 'closeTime': '02:00'},
            {'day': 'Sunday', 'openTime': '17:00', 'closeTime': '00:00'},
          ],
        },
        {
          'id': 'victorias-kitchen-luton',
          'name': "Victoria's Kitchen",
          'address': '7 Dudley Street',
          'city': 'Luton',
          'distance': 25.6,
          'latitude': 51.8792,
          'longitude': -0.4178,
          'rating': 3.9,
          'reviewCount': 144,
          'cuisineTypes': ['Nigerian', 'African', 'Caribbean'],
          'hasDelivery': true,
          'hasTakeaway': true,
          'isOpenNow': true,
          'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
          'phone': '+44 1582 535353',
          'priceRange': '££',
          'openingHours': [
            {'day': 'Monday', 'openTime': '12:00', 'closeTime': '23:00'},
            {'day': 'Tuesday', 'openTime': '12:00', 'closeTime': '23:00'},
            {'day': 'Wednesday', 'openTime': '12:00', 'closeTime': '23:00'},
            {'day': 'Thursday', 'openTime': '12:00', 'closeTime': '23:00'},
            {'day': 'Friday', 'openTime': '12:00', 'closeTime': '23:30'},
            {'day': 'Saturday', 'openTime': '12:00', 'closeTime': '23:30'},
            {'day': 'Sunday', 'openTime': '13:00', 'closeTime': '21:30'},
          ],
        },
        {
          'id': 'webs-n-roots-luton',
          'name': 'Webs N Roots',
          'address': 'Basement Floor, 47-53 Bute Street',
          'city': 'Luton',
          'distance': 25.9,
          'latitude': 51.8785,
          'longitude': -0.4195,
          'rating': 4.5,
          'reviewCount': 15,
          'cuisineTypes': ['Nigerian', 'African'],
          'hasDelivery': false,
          'hasTakeaway': true,
          'isOpenNow': true,
          'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&q=80',
          'phone': '+44 7936 412752',
          'priceRange': '£',
          'openingHours': [
            {'day': 'Monday', 'openTime': '12:00', 'closeTime': '21:00'},
            {'day': 'Tuesday', 'openTime': '12:00', 'closeTime': '21:00'},
            {'day': 'Wednesday', 'openTime': '12:00', 'closeTime': '21:00'},
            {'day': 'Thursday', 'openTime': '12:00', 'closeTime': '21:00'},
            {'day': 'Friday', 'openTime': '12:00', 'closeTime': '22:00'},
            {'day': 'Saturday', 'openTime': '12:00', 'closeTime': '22:00'},
            {'day': 'Sunday', 'openTime': '13:00', 'closeTime': '20:00'},
          ],
        },
        {
          'id': 'de-joint-hatfield',
          'name': 'De Joint Restaurants & Night Clubs',
          'address': '74-78 Town Centre',
          'city': 'Hatfield',
          'distance': 18.5,
          'latitude': 51.7636,
          'longitude': -0.2283,
          'rating': 3.8,
          'reviewCount': 45,
          'cuisineTypes': ['Nigerian', 'African', 'Caribbean'],
          'hasDelivery': false,
          'hasTakeaway': true,
          'isOpenNow': false,
          'imageUrl': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
          'phone': '+44 1707 274919',
          'priceRange': '££',
          'openingHours': [
            {'day': 'Monday', 'isClosed': true},
            {'day': 'Tuesday', 'isClosed': true},
            {'day': 'Wednesday', 'isClosed': true},
            {'day': 'Thursday', 'isClosed': true},
            {'day': 'Friday', 'openTime': '22:00', 'closeTime': '03:00'},
            {'day': 'Saturday', 'openTime': '22:00', 'closeTime': '03:00'},
            {'day': 'Sunday', 'isClosed': true},
          ],
        },
        {
          'id': 'point-one-african-hatfield',
          'name': 'Point One African Restaurant (Incognito African Lounge)',
          'address': '11-13 The Arcade',
          'city': 'Hatfield',
          'distance': 18.4,
          'latitude': 51.7630,
          'longitude': -0.2275,
          'rating': 4.0,
          'reviewCount': 26,
          'cuisineTypes': ['Nigerian', 'African'],
          'hasDelivery': true,
          'hasTakeaway': true,
          'isOpenNow': true,
          'imageUrl': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80',
          'phone': '+44 1707 709446',
          'priceRange': '££',
          'openingHours': [
            {'day': 'Monday', 'openTime': '13:00', 'closeTime': '23:30'},
            {'day': 'Tuesday', 'openTime': '13:00', 'closeTime': '23:30'},
            {'day': 'Wednesday', 'openTime': '13:00', 'closeTime': '23:30'},
            {'day': 'Thursday', 'openTime': '13:00', 'closeTime': '00:00'},
            {'day': 'Friday', 'openTime': '13:00', 'closeTime': '00:00'},
            {'day': 'Saturday', 'openTime': '13:00', 'closeTime': '00:00'},
            {'day': 'Sunday', 'openTime': '13:00', 'closeTime': '23:30'},
          ],
        },
        {
          'id': 'ogori-restaurant-stevenage',
          'name': 'Ogori Restaurant & Bar',
          'address': '7-9 The Hyde',
          'city': 'Stevenage',
          'distance': 28.2,
          'latitude': 51.9010,
          'longitude': -0.1980,
          'rating': 4.7,
          'reviewCount': 3,
          'cuisineTypes': ['Nigerian', 'African'],
          'hasDelivery': true,
          'hasTakeaway': true,
          'isOpenNow': false,
          'imageUrl': 'https://images.unsplash.com/photo-1529042410759-befb1204b468?w=800&q=80',
          'phone': '+44 1438 517518',
          'priceRange': '£££',
          'openingHours': [
            {'day': 'Monday', 'isClosed': true},
            {'day': 'Tuesday', 'openTime': '14:00', 'closeTime': '23:00'},
            {'day': 'Wednesday', 'openTime': '14:00', 'closeTime': '23:00'},
            {'day': 'Thursday', 'openTime': '14:00', 'closeTime': '23:00'},
            {'day': 'Friday', 'openTime': '14:00', 'closeTime': '23:00'},
            {'day': 'Saturday', 'openTime': '14:00', 'closeTime': '23:00'},
            {'day': 'Sunday', 'openTime': '14:00', 'closeTime': '23:00'},
          ],
        },
      ];

      int added = 0;
      int skipped = 0;

      for (final restaurant in restaurants) {
        final id = restaurant['id'] as String;

        // Check if restaurant already exists
        final doc = await _firestore.collection('restaurants').doc(id).get();

        if (doc.exists) {
          debugPrint('  ⏭️  ${restaurant['name']} - already exists');
          skipped++;
          continue;
        }

        // Add the restaurant
        await _firestore.collection('restaurants').doc(id).set(restaurant);

        debugPrint('  ✅ ${restaurant['name']} - added');
        added++;
      }

      if (added > 0) {
        debugPrint('✨ Successfully added $added new restaurants!');
      } else {
        debugPrint('✓ All additional restaurants already exist');
      }
    } catch (e) {
      debugPrint('❌ Error adding additional restaurants: $e');
      // Don't throw - we don't want to prevent app from starting
    }
  }
}
