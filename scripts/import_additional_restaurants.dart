import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  print('📊 Adding 7 additional restaurants to Firestore...\n');

  final restaurants = [
    {
      "id": "dudu-bar-luton",
      "name": "Dudu Bar Nigerian Restaurant and Lounge",
      "address": "21 High Town Rd",
      "city": "Luton",
      "postcode": "LU2 0BW",
      "latitude": 51.8847,
      "longitude": -0.4175,
      "distance": 25.5, // Approximate distance from central London
      "rating": 4.2,
      "reviewCount": 66,
      "cuisineTypes": ["Nigerian", "African"],
      "hasDelivery": true,
      "hasTakeaway": true,
      "isOpenNow": true,
      "imageUrl":
          "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&q=80",
      "phone": "+44 7542 898100",
      "website": "https://dudubarrestaurants.com",
      "priceRange": "££",
      "openingHours": [
        {"day": "Monday", "openTime": "13:00", "closeTime": "23:00"},
        {"day": "Tuesday", "openTime": "13:00", "closeTime": "23:00"},
        {"day": "Wednesday", "openTime": "13:00", "closeTime": "23:00"},
        {"day": "Thursday", "openTime": "13:00", "closeTime": "23:00"},
        {"day": "Friday", "openTime": "13:00", "closeTime": "02:00"},
        {"day": "Saturday", "openTime": "13:00", "closeTime": "02:00"},
        {"day": "Sunday", "openTime": "13:00", "closeTime": "22:00"},
      ],
    },
    {
      "id": "pades-lounge-luton",
      "name": "Pades Lounge African",
      "address": "39 Wellington Street",
      "city": "Luton",
      "postcode": "LU1 2QH",
      "latitude": 51.8797,
      "longitude": -0.4152,
      "distance": 25.8,
      "rating": 4.0,
      "reviewCount": 120,
      "cuisineTypes": ["Nigerian", "African"],
      "hasDelivery": true,
      "hasTakeaway": true,
      "isOpenNow": false,
      "imageUrl":
          "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80",
      "phone": "+44 1582 518158",
      "website": "https://www.padesrestaurant.co.uk",
      "priceRange": "££",
      "openingHours": [
        {"day": "Monday", "openTime": "12:30", "closeTime": "00:00"},
        {"day": "Tuesday", "openTime": "12:30", "closeTime": "00:00"},
        {"day": "Wednesday", "openTime": "12:30", "closeTime": "00:00"},
        {"day": "Thursday", "openTime": "12:30", "closeTime": "00:00"},
        {"day": "Friday", "openTime": "12:00", "closeTime": "03:00"},
        {"day": "Saturday", "openTime": "13:00", "closeTime": "02:00"},
        {"day": "Sunday", "openTime": "17:00", "closeTime": "00:00"},
      ],
    },
    {
      "id": "victorias-kitchen-luton",
      "name": "Victoria's Kitchen",
      "address": "7 Dudley Street",
      "city": "Luton",
      "postcode": "LU2 0NP",
      "latitude": 51.8792,
      "longitude": -0.4178,
      "distance": 25.6,
      "rating": 3.9,
      "reviewCount": 144,
      "cuisineTypes": ["Nigerian", "African", "Caribbean"],
      "hasDelivery": true,
      "hasTakeaway": true,
      "isOpenNow": true,
      "imageUrl":
          "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80",
      "phone": "+44 1582 535353",
      "website": "https://victoria-kitchen.com",
      "priceRange": "££",
      "openingHours": [
        {"day": "Monday", "openTime": "12:00", "closeTime": "23:00"},
        {"day": "Tuesday", "openTime": "12:00", "closeTime": "23:00"},
        {"day": "Wednesday", "openTime": "12:00", "closeTime": "23:00"},
        {"day": "Thursday", "openTime": "12:00", "closeTime": "23:00"},
        {"day": "Friday", "openTime": "12:00", "closeTime": "23:30"},
        {"day": "Saturday", "openTime": "12:00", "closeTime": "23:30"},
        {"day": "Sunday", "openTime": "13:00", "closeTime": "21:30"},
      ],
    },
    {
      "id": "webs-n-roots-luton",
      "name": "Webs N Roots",
      "address": "Basement Floor, 47-53 Bute Street",
      "city": "Luton",
      "postcode": "LU1 2EP",
      "latitude": 51.8785,
      "longitude": -0.4195,
      "distance": 25.9,
      "rating": 4.5,
      "reviewCount": 15,
      "cuisineTypes": ["Nigerian", "African"],
      "hasDelivery": false,
      "hasTakeaway": true,
      "isOpenNow": true,
      "imageUrl":
          "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&q=80",
      "phone": "+44 7936 412752",
      "website": "https://www.websandroots.com",
      "priceRange": "£",
      "openingHours": [
        {"day": "Monday", "openTime": "12:00", "closeTime": "21:00"},
        {"day": "Tuesday", "openTime": "12:00", "closeTime": "21:00"},
        {"day": "Wednesday", "openTime": "12:00", "closeTime": "21:00"},
        {"day": "Thursday", "openTime": "12:00", "closeTime": "21:00"},
        {"day": "Friday", "openTime": "12:00", "closeTime": "22:00"},
        {"day": "Saturday", "openTime": "12:00", "closeTime": "22:00"},
        {"day": "Sunday", "openTime": "13:00", "closeTime": "20:00"},
      ],
    },
    {
      "id": "de-joint-hatfield",
      "name": "De Joint Restaurants & Night Clubs",
      "address": "74-78 Town Centre",
      "city": "Hatfield",
      "postcode": "AL10 0JZ",
      "latitude": 51.7636,
      "longitude": -0.2283,
      "distance": 18.5,
      "rating": 3.8,
      "reviewCount": 45,
      "cuisineTypes": ["Nigerian", "African", "Caribbean"],
      "hasDelivery": false,
      "hasTakeaway": true,
      "isOpenNow": false,
      "imageUrl":
          "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80",
      "phone": "+44 1707 274919",
      "priceRange": "££",
      "openingHours": [
        {"day": "Monday", "isClosed": true},
        {"day": "Tuesday", "isClosed": true},
        {"day": "Wednesday", "isClosed": true},
        {"day": "Thursday", "isClosed": true},
        {"day": "Friday", "openTime": "22:00", "closeTime": "03:00"},
        {"day": "Saturday", "openTime": "22:00", "closeTime": "03:00"},
        {"day": "Sunday", "isClosed": true},
      ],
    },
    {
      "id": "point-one-african-hatfield",
      "name": "Point One African Restaurant (Incognito African Lounge)",
      "address": "11-13 The Arcade",
      "city": "Hatfield",
      "postcode": "AL10 0JY",
      "latitude": 51.7630,
      "longitude": -0.2275,
      "distance": 18.4,
      "rating": 4.0,
      "reviewCount": 26,
      "cuisineTypes": ["Nigerian", "African"],
      "hasDelivery": true,
      "hasTakeaway": true,
      "isOpenNow": true,
      "imageUrl":
          "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80",
      "phone": "+44 1707 709446",
      "website": "https://www.incognitoafricanlounge.com",
      "priceRange": "££",
      "openingHours": [
        {"day": "Monday", "openTime": "13:00", "closeTime": "23:30"},
        {"day": "Tuesday", "openTime": "13:00", "closeTime": "23:30"},
        {"day": "Wednesday", "openTime": "13:00", "closeTime": "23:30"},
        {"day": "Thursday", "openTime": "13:00", "closeTime": "00:00"},
        {"day": "Friday", "openTime": "13:00", "closeTime": "00:00"},
        {"day": "Saturday", "openTime": "13:00", "closeTime": "00:00"},
        {"day": "Sunday", "openTime": "13:00", "closeTime": "23:30"},
      ],
    },
    {
      "id": "ogori-restaurant-stevenage",
      "name": "Ogori Restaurant & Bar",
      "address": "7-9 The Hyde",
      "city": "Stevenage",
      "postcode": "SG2 9SD",
      "latitude": 51.9010,
      "longitude": -0.1980,
      "distance": 28.2,
      "rating": 4.7,
      "reviewCount": 3,
      "cuisineTypes": ["Nigerian", "African"],
      "hasDelivery": true,
      "hasTakeaway": true,
      "isOpenNow": false,
      "imageUrl":
          "https://images.unsplash.com/photo-1529042410759-befb1204b468?w=800&q=80",
      "phone": "+44 1438 517518",
      "website": "http://www.eatogori.com",
      "priceRange": "£££",
      "openingHours": [
        {"day": "Monday", "isClosed": true},
        {"day": "Tuesday", "openTime": "14:00", "closeTime": "23:00"},
        {"day": "Wednesday", "openTime": "14:00", "closeTime": "23:00"},
        {"day": "Thursday", "openTime": "14:00", "closeTime": "23:00"},
        {"day": "Friday", "openTime": "14:00", "closeTime": "23:00"},
        {"day": "Saturday", "openTime": "14:00", "closeTime": "23:00"},
        {"day": "Sunday", "openTime": "14:00", "closeTime": "23:00"},
      ],
    },
  ];

  int added = 0;
  int skipped = 0;

  for (final restaurant in restaurants) {
    final id = restaurant['id'] as String;

    // Check if restaurant already exists
    final doc = await firestore.collection('restaurants').doc(id).get();

    if (doc.exists) {
      print('⏭️  ${restaurant['name']} - already exists, skipping');
      skipped++;
      continue;
    }

    // Add the restaurant
    await firestore.collection('restaurants').doc(id).set(restaurant);

    print('✅ ${restaurant['name']} - added successfully');
    print('   📍 ${restaurant['address']}, ${restaurant['city']}');
    print('   ⭐ ${restaurant['rating']} (${restaurant['reviewCount']} reviews)');
    print('');

    added++;
  }

  print('\n✨ Import complete!');
  print('   ✅ Added: $added restaurants');
  print('   ⏭️  Skipped: $skipped restaurants (already exist)');
  print('   📊 Total in data: ${restaurants.length} restaurants');
}
