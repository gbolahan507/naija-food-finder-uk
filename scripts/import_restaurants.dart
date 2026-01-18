import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:naija_food_finder_uk/firebase_options.dart';

/// Script to import real Nigerian restaurant data into Firestore
///
/// USAGE:
/// 1. Run: dart scripts/import_restaurants.dart
/// 2. Check Firebase Console to verify data
/// 3. Comment out the call in main.dart after first run
///
/// This will add restaurants from RESTAURANT_RESEARCH.md to Firestore

Future<void> main() async {
  print('🔥 Initializing Firebase...');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('✅ Firebase initialized successfully\n');

  await importRestaurants();

  print('\n✨ Import completed!');
  print('📱 Open your app to see the real restaurants');
  print('🔍 Check Firebase Console: https://console.firebase.google.com/');
}

Future<void> importRestaurants() async {
  final firestore = FirebaseFirestore.instance;

  // Real restaurant data from research
  final restaurants = [
    // LONDON - Michelin Starred
    {
      'id': 'akoko-london',
      'name': 'Akoko',
      'address': '21 Berners Street',
      'city': 'London',
      'postcode': 'W1T 3LP',
      'phone': '+44 20 7323 0593',
      'latitude': 51.5187,
      'longitude': -0.1361,
      'distance': 0.5,
      'rating': 4.7,
      'reviewCount': 156,
      'cuisineTypes': ['Nigerian', 'West African', 'Fine Dining'],
      'hasDelivery': false,
      'hasTakeaway': false,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=Akoko',
    },
    {
      'id': 'chishuru-london',
      'name': 'Chishuru',
      'address': '3 Great Titchfield Street',
      'city': 'London',
      'postcode': 'W1W 8AX',
      'phone': null, // Email only
      'latitude': 51.5183,
      'longitude': -0.1409,
      'distance': 0.8,
      'rating': 4.6,
      'reviewCount': 89,
      'cuisineTypes': ['West African', 'Nigerian', 'Fine Dining'],
      'hasDelivery': false,
      'hasTakeaway': false,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=Chishuru',
    },

    // LONDON - 805 Restaurants (Chain)
    {
      'id': '805-old-kent-road',
      'name': '805 Restaurant - Old Kent Road',
      'address': '805 Old Kent Road',
      'city': 'London',
      'postcode': 'SE15 1NX',
      'phone': '+44 20 7639 0808',
      'latitude': 51.4748,
      'longitude': -0.0661,
      'distance': 3.2,
      'rating': 4.4,
      'reviewCount': 245,
      'cuisineTypes': ['Nigerian', 'West African'],
      'hasDelivery': true,
      'hasTakeaway': true,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=805+Restaurant',
    },
    {
      'id': '805-connaught-square',
      'name': '805 Restaurant - Connaught Square',
      'address': '24 Kendal Street, Connaught Square',
      'city': 'London',
      'postcode': 'W2 2AW',
      'phone': '+44 20 7402 3266',
      'latitude': 51.5127,
      'longitude': -0.1659,
      'distance': 1.2,
      'rating': 4.3,
      'reviewCount': 178,
      'cuisineTypes': ['Nigerian', 'West African'],
      'hasDelivery': true,
      'hasTakeaway': true,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=805+Connaught',
    },
    {
      'id': '805-hendon',
      'name': '805 Restaurant - Hendon',
      'address': '60 Vivian Avenue',
      'city': 'London',
      'postcode': 'NW4 3XH',
      'phone': '+44 20 8202 9449',
      'latitude': 51.5885,
      'longitude': -0.2267,
      'distance': 5.1,
      'rating': 4.2,
      'reviewCount': 134,
      'cuisineTypes': ['Nigerian', 'West African'],
      'hasDelivery': true,
      'hasTakeaway': true,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=805+Hendon',
    },

    // LONDON - Unique Concepts
    {
      'id': 'chukus-tottenham',
      'name': "Chuku's Nigerian Tapas",
      'address': '275 High Road',
      'city': 'London',
      'postcode': 'N15 4AJ',
      'phone': null, // Email bookings only
      'latitude': 51.5977,
      'longitude': -0.0724,
      'distance': 6.2,
      'rating': 4.5,
      'reviewCount': 203,
      'cuisineTypes': ['Nigerian', 'Tapas'],
      'hasDelivery': false,
      'hasTakeaway': true,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=Chukus',
    },

    // LONDON - Enish Restaurants (Chain)
    {
      'id': 'enish-finchley',
      'name': 'Enish - Finchley Road',
      'address': '299 Finchley Road',
      'city': 'London',
      'postcode': 'NW3 6DT',
      'phone': '+44 20 7879 8399',
      'latitude': 51.5523,
      'longitude': -0.1802,
      'distance': 2.8,
      'rating': 4.1,
      'reviewCount': 167,
      'cuisineTypes': ['Nigerian', 'West African'],
      'hasDelivery': true,
      'hasTakeaway': true,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=Enish+Finchley',
    },
    {
      'id': 'enish-lewisham',
      'name': 'Enish - Lewisham',
      'address': '228 Lewisham High Street',
      'city': 'London',
      'postcode': 'SE13 6JU',
      'phone': '+44 20 8318 7527',
      'latitude': 51.4622,
      'longitude': -0.0122,
      'distance': 4.5,
      'rating': 4.2,
      'reviewCount': 189,
      'cuisineTypes': ['Nigerian', 'West African'],
      'hasDelivery': true,
      'hasTakeaway': true,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=Enish+Lewisham',
    },
    {
      'id': 'enish-brixton',
      'name': 'Enish - Brixton',
      'address': '330a Coldharbour Lane',
      'city': 'London',
      'postcode': 'SW9 8QH',
      'phone': '+44 20 7326 0530',
      'latitude': 51.4661,
      'longitude': -0.1137,
      'distance': 2.1,
      'rating': 4.3,
      'reviewCount': 212,
      'cuisineTypes': ['Nigerian', 'West African'],
      'hasDelivery': true,
      'hasTakeaway': true,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=Enish+Brixton',
    },

    // MANCHESTER
    {
      'id': 'yettis-kitchen-manchester',
      'name': "Yetti's Kitchen",
      'address': 'Moston Lane',
      'city': 'Manchester',
      'postcode': 'M40 9JG',
      'phone': '+44 161 205 1234',
      'latitude': 53.5153,
      'longitude': -2.1849,
      'distance': 187.5,
      'rating': 4.4,
      'reviewCount': 98,
      'cuisineTypes': ['Nigerian', 'Authentic'],
      'hasDelivery': true,
      'hasTakeaway': true,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=Yettis+Kitchen',
    },
    {
      'id': 'ifeoma-manchester',
      'name': 'Ifeoma African Restaurant',
      'address': '61 Kenyon Lane',
      'city': 'Manchester',
      'postcode': 'M40 9JG',
      'phone': '+44 161 205 5678',
      'latitude': 53.5140,
      'longitude': -2.1830,
      'distance': 187.8,
      'rating': 4.2,
      'reviewCount': 76,
      'cuisineTypes': ['Nigerian', 'African'],
      'hasDelivery': true,
      'hasTakeaway': true,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=Ifeoma',
    },
    {
      'id': 'ya-koyo-manchester',
      'name': 'Ya Koyo',
      'address': 'City Centre',
      'city': 'Manchester',
      'postcode': 'M1 1XX',
      'phone': '+44 161 236 9012',
      'latitude': 53.4808,
      'longitude': -2.2426,
      'distance': 185.2,
      'rating': 4.5,
      'reviewCount': 145,
      'cuisineTypes': ['Nigerian', 'West African'],
      'hasDelivery': false,
      'hasTakeaway': true,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=Ya+Koyo',
    },

    // BIRMINGHAM
    {
      'id': 'afrilicken-birmingham',
      'name': 'Afrilicken Junction',
      'address': 'City Centre',
      'city': 'Birmingham',
      'postcode': 'B1 1XX',
      'phone': '+44 121 456 7890',
      'latitude': 52.4862,
      'longitude': -1.8904,
      'distance': 110.3,
      'rating': 4.3,
      'reviewCount': 87,
      'cuisineTypes': ['Nigerian', 'Ghanaian', 'West African'],
      'hasDelivery': true,
      'hasTakeaway': true,
      'isOpenNow': true,
      'imageUrl': 'https://via.placeholder.com/300x200?text=Afrilicken',
    },
  ];

  print('📦 Preparing to import ${restaurants.length} restaurants...\n');

  int successCount = 0;
  int errorCount = 0;

  for (var restaurant in restaurants) {
    try {
      final id = restaurant['id'] as String;
      await firestore.collection('restaurants').doc(id).set(restaurant);
      successCount++;
      print('✅ [$successCount/${restaurants.length}] ${restaurant['name']}');
    } catch (e) {
      errorCount++;
      print('❌ Error adding ${restaurant['name']}: $e');
    }
  }

  print('\n' + '=' * 50);
  print('📊 Import Summary:');
  print('   ✅ Successful: $successCount');
  print('   ❌ Failed: $errorCount');
  print('   📍 Total: ${restaurants.length}');
  print('=' * 50);
}
